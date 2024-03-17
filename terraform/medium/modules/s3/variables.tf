variable "lifecycle_rules" {
  description = "A list of lifecycle rules"
  type        = list(any)
  default     = []
}

variable "namespace" {
  description = "The owner of the bucket"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "the geo environment of the bucket"
  type        = string
  default     = "default"
}

variable "stage" {
  description = "The environment stage of the bucket"
  type        = string
  default     = "default"
}

variable "name" {
  description = "The module context name"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "A map of tags"
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  description = "Enable versioning"
  type        = bool
  default     = false
}