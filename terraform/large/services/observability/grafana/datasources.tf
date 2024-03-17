module "datasources-shared-ec1" {
  source = "./modules/datasources"

  datasources = {
    thanos = {
      enabled = true
      name    = "Thanos"
      type    = "prometheus"
      url     = "https://thanos.${local.domain_name}"
      default = true
    }
    loki = {
      enabled = true
      name    = "Loki"
      type    = "loki"
      url     = "https://gateway.loki.${local.domain_name}"
    }
    #FIXME customer: if tempo is deployed, enable this datasource
    tempo = {
      enabled = false
      name    = "Tempo"
      type    = "tempo"
      url     = "https://gateway.tempo.${local.domain_name}"
    }
  }
}
