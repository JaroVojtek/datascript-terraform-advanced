output "vpc_id" {
  description = "ID of the VPC"
  value       = try(module.vpc[0].vpc_id, "")
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = try(module.vpc[0].vpc_cidr_block, "")
}

output "public_root_zone_name" {
  description = "Name of the public root zone"
  value       = try(aws_route53_zone.public_root.name, "")
}

output "public_root_zone_id" {
  description = "Name of the public root zone"
  value       = try(aws_route53_zone.public_root.zone_id, "")
}