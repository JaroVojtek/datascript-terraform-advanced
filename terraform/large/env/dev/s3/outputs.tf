output "s3" {
  description = "S3 module attributes"
  value       = try(module.s3, {})
  sensitive   = true
}