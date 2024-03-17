variable "folders" {
  type        = map(any)
  description = "A map of Grafana folders to create dashboard from. Key is the folder path, value is the grafana_folder resource outputs"
}
