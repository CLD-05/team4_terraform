variable "project_name" {
  type        = string
  description = "프로젝트 이름 prefix (예: team4)"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS 모듈에서 출력(Output)된 IAM OpenID Connect Provider ARN"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS 모듈에서 출력(Output)된 EKS 클러스터의 OIDC Issuer URL"
}
