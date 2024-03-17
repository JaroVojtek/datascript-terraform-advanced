output "iam_role_arn" {
  description = "The ARN of the IAM role created for the CloudWatch"
  value       = aws_iam_role.this.arn
}
