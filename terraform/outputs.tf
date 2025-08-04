output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions OIDC."
  value       = aws_iam_role.github_actions.arn
}
