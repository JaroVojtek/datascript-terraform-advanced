module "folders-shared-ec1" {
  source = "./modules/folders"

  folders = {
    apps                    = "Applications"
    "apps/generated"        = "Applications / Generated"
    services                = "Services"
    "services/service-mesh" = "Services / Service Mesh"
    system                  = "System"
    "system/generated"      = "System / Generated"
  }
}
