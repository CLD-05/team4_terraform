variable "domain_name" {
  type        = string
  description = "도메인 이름"
  default     = "singleuser.cloud"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS 이름"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB Zone ID"
}
