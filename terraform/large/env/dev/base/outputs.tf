output "vpc_id" {
  description = "ID of the VPC"
  value       = try(module.vpc[0].vpc_id, "")
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = try(module.vpc[0].vpc_cidr_block, "")
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
