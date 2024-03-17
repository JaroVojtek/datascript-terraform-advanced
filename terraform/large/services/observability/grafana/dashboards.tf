module "dashboards-shared-ec1" {
  source = "./modules/dashboards"

  folders = module.folders-shared-ec1.folders
}
