variable "vpc_id" {
  type        = string
  description = "VPC ID from VPC module"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs for RDS Subnet Group"
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}