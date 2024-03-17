resource "grafana_folder" "folders" {
  for_each = var.folders

  uid   = replace(each.key, "/", "-")
  title = each.value
}

resource "grafana_folder_permission" "permissions" {
  for_each = var.folders

  folder_uid = grafana_folder.folders[each.key].uid

  permissions {
    role       = "Editor"
    permission = "Edit"
  }

  permissions {
    role       = "Viewer"
    permission = "View"
  }
}
