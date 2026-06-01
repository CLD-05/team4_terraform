output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "DynamoDB 테이블 이름"
  value       = aws_dynamodb_table.terraform_lock.name
}
