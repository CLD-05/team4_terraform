variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC Provider URL"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS OIDC Provider ARN"
}

variable "github_repo" {
  type        = string
  description = "GitHub 레포 주소"
}