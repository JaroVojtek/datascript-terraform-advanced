variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks for ingress"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}
