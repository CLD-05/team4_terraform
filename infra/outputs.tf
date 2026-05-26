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
  
output "iam_test_s3_bucket" {
  description = "내가 만든 모듈의 S3 버킷 이름"
  value       = module.iam.s3_bucket_name
}

output "iam_test_irsa_role" {
  description = "내가 만든 모듈의 IAM Role ARN"
  value       = module.iam.s3_reader_role_arn
}
