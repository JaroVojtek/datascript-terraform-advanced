variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "accepter_options" {
  default     = {}
  description = "An optional configuration block that allows for VPC Peering Connection options to be set for the VPC that accepts the peering connection (a maximum of one)."
  type        = map(string)
}

variable "accepter_tags" {
  default     = {}
  description = "Tags to add to the accepter side resources of the connection."
  type        = map(string)
}

variable "accepter_vpc_cidr" {
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
  type        = string
}

variable "requester_options" {
  default     = {}
  description = "A optional configuration block that allows for VPC Peering Connection options to be set for the VPC that requests the peering connection (a maximum of one)."
  type        = map(string)
}

variable "requester_tags" {
  default     = {}
  description = "Tags to add to the requester side resources of the connection."
  type        = map(string)
}

variable "requester_vpc_cidr" {
  description = "The ID of the requester VPC."
  type        = string
}
