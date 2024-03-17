locals {
  log_retention_days  = 60
  log_retention_hours = local.log_retention_days * 24

  # FIXME customer: disable when you do not want to use memcache for Loki acceleration
  memcache_enabled = true
}

module "loki-shared-ec1" {
  source = "github.com/lablabs/terraform-aws-eks-loki.git?ref=v0.2.1"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }

  helm_chart_version = "0.69.16"

  namespace = "logging"

  cluster_identity_oidc_issuer     = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn

  service_account_name     = "loki-distributed"
  irsa_role_name_prefix    = "${module.label-shared-ec1.id}-loki-eks"
  irsa_additional_policies = { loki_shared_ec1 = aws_iam_policy.loki_shared_ec1.arn }

  values = yamlencode({
    "global" : {
      "priorityClassName" : "platform-critical"
    }
    "loki" : {
      "podLabels" : local.loki_common_labels
      "podAnnotations" : {
        "cluster-autoscaler.kubernetes.io/safe-to-evict" : "true"
      }
      "structuredConfig" : {
        "ingester" : {
          "autoforget_unhealthy" : true
        }
      }
      "schemaConfig" : {
        "configs" : [
          {
            "from" : "2020-10-24",
            "store" : "aws",
            "object_store" : "s3",
            "schema" : "v11",
            "index" : {
              "prefix" : "loki_index_",
              "period" : "24h"
            }
          }
        ]
      }
      "storageConfig" : {
        "boltdb_shipper" : null
        "filesystem" : null
        "aws" : {
          "s3" : "s3://${data.aws_region.current.name}/${module.loki-shared-ec1-bucket.bucket_id}"
          "dynamodb" : {
            "dynamodb_url" : "dynamodb://${data.aws_region.current.name}"
          }
        }
      }
    }
    "gateway" : {
      "replicas" : 2
      "maxUnavailable" : 1
      "ingress" : {
        "enabled" : true
        "ingressClassName" : "nginx-internal"
        "annotations" : {
          "nginx.ingress.kubernetes.io/ssl-redirect" : "true"
          "nginx.ingress.kubernetes.io/force-ssl-redirect" : "true"
          "cert-manager.io/cluster-issuer" : "default"
        }
        "hosts" : [{
          "host" : "gateway.loki.${module.label-shared-ec1.environment}.${data.terraform_remote_state.def.outputs.root_dns_name}",
          "paths" : [
            {
              "path" : "/"
              "pathType" : "Prefix"
            }
          ]
        }],
        "tls" : [
          {
            "secretName" : "loki-gateway-tls-certificate",
            "hosts" : [
              "gateway.loki.${module.label-shared-ec1.environment}.${data.terraform_remote_state.def.outputs.root_dns_name}"
            ]
          }
        ]
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "20m"
          "memory" : "32Mi"
        }
      }
    }
    "tableManager" : {
      "enabled" : true
      "extraArgs" : [
        "-table-manager.retention-deletes-enabled=true",
        "-table-manager.retention-period=${local.log_retention_hours}h",
        "-table-manager.index-table.enable-ondemand-throughput-mode=true",
        "-table-manager.index-table.inactive-enable-ondemand-throughput-mode=true"
      ]
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "10m"
          "memory" : "32Mi"
        }
      }
    }
    "compactor" : {
      "enabled" : true
      "persistence" : {
        "enabled" : true
        "size" : "10Gi"
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "10m"
          "memory" : "32Mi"
        }
      }
    }
    "distributor" : {
      "replicas" : 2
      "maxUnavailable" : 1
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "200m"
          "memory" : "128Mi"
        }
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 6
        "targetCPUUtilizationPercentage" : 120
        "targetMemoryUtilizationPercentage" : 200
      }
    }
    "querier" : {
      "replicas" : 3
      "maxUnavailable" : 1
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "500m"
          "memory" : "512Mi"
        }
      }
    }
    "queryFrontend" : {
      "podLabels" : local.loki_common_labels
      "maxUnavailable" : 1
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "200m"
          "memory" : "128Mi"
        }
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 4
        "targetCPUUtilizationPercentage" : 120
        "targetMemoryUtilizationPercentage" : 200
      }
    }
    "ingester" : {
      "replicas" : 2
      "maxUnavailable" : 1
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
      "resources" : {
        "requests" : {
          "cpu" : "600m"
          "memory" : "512Mi"
        }
      }
      "persistence" : {
        "enabled" : true
        "claims" : [
          {
            "name" : "data"
            "size" : "50Gi"
            "storageClass" : "ebs-csi-gp3"
          }
        ]
      }
      "autoscaling" : {
        "enabled" : true
        "minReplicas" : 2
        "maxReplicas" : 6
        "targetCPUUtilizationPercentage" : 120
        "targetMemoryUtilizationPercentage" : 400
      }
    }
    # configuration for memcache
    "memcachedChunks" : {
      "enabled" : local.memcache_enabled
      # command line arguments = https://github.com/memcached/memcached/wiki/ConfiguringServer#commandline-arguments
      # man memcahced = https://linux.die.net/man/1/memcached
      "extraArgs" : [
        "-I 2m",
        "-m 2048",
        "-v"
      ]
      "persistence" : {
        "enabled" : false
        "size" : "10Gi"
        "storageClass" : "ebs-csi-gp3"
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
    }
    "memcachedFrontend" : {
      "enabled" : local.memcache_enabled
      "persistence" : {
        "enabled" : true
        "size" : "10Gi"
        "storageClass" : "ebs-csi-gp3"
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
    }
    "memcachedIndexWrites" : {
      "enabled" : local.memcache_enabled
      "persistence" : {
        "enabled" : true
        "size" : "10Gi"
        "storageClass" : "ebs-csi-gp3"
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
    }
    "memcachedIndexQueries" : {
      "enabled" : local.memcache_enabled
      "persistence" : {
        "enabled" : true
        "size" : "10Gi"
        "storageClass" : "ebs-csi-gp3"
      }
      "nodeSelector" : local.loki_common_node_selector
      "tolerations" : local.loki_common_tolerations
    }
    "memcachedExporter" : {
      "enabled" : local.memcache_enabled
    }
  })
}
