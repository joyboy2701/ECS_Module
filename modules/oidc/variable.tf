variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-role"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = list(string)
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "GitHubActionsPolicy"
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = "Permissions for GitHub Actions to push Docker images and manage ECS"
}

variable "policy_actions" {
  description = "List of AWS actions allowed for the IAM policy"
  type        = list(string)
}

variable "github_thumbprint" {
  description = "OIDC thumbprint for GitHub Actions"
  type        = string
}
