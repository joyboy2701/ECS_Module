output "repository_url" {
  value       = try(aws_ecr_repository.this.repository_url, null)
  description = "ECR repository URL"
}

output "repository_arn" {
  value       = try(aws_ecr_repository.this.arn, null)
  description = "ECR repository ARN"
}
