variable "datasources" {
  type        = map(any)
  default     = {}
  description = <<EOF
    A map of datasource names to datasource configuration blocks

    ```
    datasource = {
      enabled           = bool   # optional, defaults to false
      name              = string # required
      type              = string # required
      url               = string # optional, defaults to empty value
      json_data_encoded = string # optional, defaults to empty value
      access            = string # optional, defaults to proxy, can be direct or proxy
      default           = bool   # optional, defaults to false
    #}
    ```
  EOF
}
