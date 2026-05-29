variable "project_name" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "diary_bucket_arn" {
  type        = string
  description = "Diary 이미지 S3 버킷 ARN"
}

variable "app_service_account_name" {
  type    = string
  default = "diary-app-sa"
}

variable "app_namespaces" {
  type    = list(string)
  default = ["diary-app", "diary-app-dev", "diary-app-prod"]
}
