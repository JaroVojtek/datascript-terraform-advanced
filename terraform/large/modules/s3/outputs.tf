output "s3" {
  description = "S3 module attributes"
  value       = try(module.s3, {})
  sensitive   = true
}

output "kms_key" {
  description = "KMS key module attributes"
  value       = try(module.kms_key, {})
}
