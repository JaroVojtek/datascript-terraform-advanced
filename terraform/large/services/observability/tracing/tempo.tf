locals {
  # retention used in s3 bucket lifecycle policy
  retention_days = 60
  # block retention hours used for compactor
  block_retention_hours = local.retention_days * 24
  # if log received spans should be enabled or not in distributor config
  log_received_spans = false
  # max block size for compactor. 10^13 = 10TB
  max_block_bytes = pow(10, 13)
  # grpc server max size in bytes used for send and receive messages. 134217728 = 128Mib
  grpc_server_max_msg_size = 134217728
}

module "tempo-shared-ec1" {
  source = "github.com/lablabs/terraform-aws-eks-tempo.git?ref=v0.1.0"

  enabled   = true
  namespace = "tracing"

  helm_chart_version = "1.6.2"

  cluster_identity_oidc_issuer     = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn
  service_account_name             = "tempo-distributed"
  irsa_role_name_prefix            = "${module.label-shared-ec1.id}-tempo-eks"
  irsa_additional_policies         = { tempo_shared_ec1 = aws_iam_policy.tempo_shared_ec1.arn }

  argo_enabled      = true
  argo_helm_enabled = false
  argo_sync_policy = {
    automated   = {}
    syncOptions = ["CreateNamespace=true"]
  }

  values = yamlencode({
    "global" : {
      "priorityClassName" : "platform-critical"
    }
    "tempo" : {
      "podLabels" : {
        "monitoring/scope" : "system"
      }
      "podAnnotations" : {
        "cluster-autoscaler.kubernetes.io/safe-to-evict" : "true"
      }
    }
    "server" : {
      "grpc_server_max_recv_msg_size" : local.grpc_server_max_msg_size
      "grpc_server_max_send_msg_size" : local.grpc_server_max_msg_size
    }
    # Traces configuration to Tempo
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L736
    "traces" : {
      "otlp" : {
        "grpc" : {
          "enabled" : true
        }
        "http" : {
          "enabled" : true
        }
      }
      # "jaeger" : {
      #   "grpc" : {
      #     "enabled" : true
      #   }
      #   "thriftHttp" : {
      #     "enabled" : true
      #   }
      #   "thriftCompact" : {
      #     "enabled" : true
      #   }
      # }
    }
    # Backend storage configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L1077
    "storage" : {
      "trace" : {
        "backend" : "s3"
        "s3" : {
          "bucket" : module.tempo-shared-ec1-bucket.bucket_id
          "endpoint" : "s3.dualstack.${data.aws_region.current.name}.amazonaws.com"
        }
      }
    }
    # Gateway configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L1330
    "gateway" : {
      "enabled" : true
      "replicas" : 2
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "gateway") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "gateway") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "nginxConfig" : {
        "serverSnippet" : <<-EOF
          location = /opentelemetry.proto.collector.trace.v1.TraceService/Export {
            grpc_pass       tempo-distributor.tracing.svc.cluster.local:4317;
          }
          EOF
      }
      "ingress" : {
        "enabled" : true
        "ingressClassName" : "nginx-internal"
        "annotations" : {
          "nginx.ingress.kubernetes.io/ssl-redirect" : "true"
          "nginx.ingress.kubernetes.io/force-ssl-redirect" : "true"
          "cert-manager.io/cluster-issuer" : "default"
        }
        "hosts" : [{
          "host" : "gateway.tempo.${module.label-shared-ec1.environment}.${data.terraform_remote_state.def.outputs.root_dns_name}",
          "paths" : [
            {
              "path" : "/"
              "pathType" : "Prefix"
            }
          ]
        }],
        "tls" : [
          {
            "secretName" : "tempo-gateway-tls-certificate",
            "hosts" : [
              "gateway.tempo.${module.label-shared-ec1.environment}.${data.terraform_remote_state.def.outputs.root_dns_name}"
            ]
          }
        ]
      }
      "resources" : {
        "requests" : {
          "cpu" : "10m"
          "memory" : "32Mi"
        }
      }
    }
    # Compactor configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L434
    "compactor" : {
      "config" : {
        "compaction" : {
          "block_retention" : "${local.block_retention_hours}h"
          "max_block_bytes" : local.max_block_bytes
        }
      }
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "compactor") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "compactor") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "50m"
          "memory" : "1024Mi"
        }
      }
    }
    # Distributor configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L335
    "distributor" : {
      "config" : {
        "log_received_spans" : {
          "enabled" : local.log_received_spans
          "include_all_attributes" : true
        }
      }
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "distributor") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "distributor") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "200m"
          "memory" : "256Mi"
        }
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 6
        "targetCPUUtilizationPercentage" : 80
        "targetMemoryUtilizationPercentage" : 90
      }
    }
    # Querier configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L499
    "querier" : {
      "replicas" : 3
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "querier") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "querier") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "500m"
          "memory" : "512Mi"
        }
      }
    }
    # Query Frontend configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L601
    "queryFrontend" : {
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "query-frontend") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "query-frontend") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "200m"
          "memory" : "256Mi"
        }
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 4
        "targetCPUUtilizationPercentage" : 80
        "targetMemoryUtilizationPercentage" : 90
      }
    }
    # Ingester configuration
    # https://github.com/grafana/helm-charts/blob/tempo-distributed-1.2.7/charts/tempo-distributed/values.yaml#L101
    "ingester" : {
      "topologySpreadConstraints" : <<-EOF
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: ScheduleAnyway
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "ingester") | nindent 6 }}
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              {{- include "tempo.selectorLabels" (dict "ctx" . "component" "ingester") | nindent 6 }}
      EOF
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "600m"
          "memory" : "512Mi"
        }
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 6
        "targetCPUUtilizationPercentage" : 80
        "targetMemoryUtilizationPercentage" : 90
      }
    }
    "memcached" : {
      "podLabels" : {
        "monitoring/scope" : "system"
      }
      "priorityClassName" : "platform-critical"
      "nodeSelector" : local.tempo_common_node_selector
      "tolerations" : local.tempo_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "100m"
          "memory" : "128Mi"
        }
      }
    }
  })
}
