output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet ID 목록"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet ID 목록"
  value       = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  description = "DB Subnet ID 목록"
  value       = module.vpc.db_subnet_ids
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = module.vpc.alb_sg_id
}

output "eks_node_sg_id" {
  description = "EKS Node Security Group ID"
  value       = module.vpc.eks_node_sg_id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = module.vpc.rds_sg_id
}

output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = module.backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "DynamoDB 테이블 이름"
  value       = module.backend.dynamodb_table_name
}

output "cloudfront_domain" {
  description = "CloudFront 도메인 (이미지 URL)"
  value       = module.s3.cloudfront_domain
}

output "diary_bucket_name" {
  description = "이미지 저장 S3 버킷 이름"
  value       = module.s3.bucket_name
}
