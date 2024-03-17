output "ses" {
  description = "SES module attributes"
  value       = try(module.ses, {})
}

