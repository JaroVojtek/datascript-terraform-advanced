output "vpc_id" {
  description = "ID of the VPC"
  value       = try(module.vpc[0].vpc_id, "")
}