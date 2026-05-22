output "s3_bucket_name" {
  description = "생성된 IRSA 테스트용 S3 버킷 이름"
  value       = aws_s3_bucket.irsa_test.bucket
}

output "s3_reader_role_arn" {
  description = "쿠버네티스 ServiceAccount에 어노테이션으로 등록할 IAM Role ARN"
  value       = aws_iam_role.s3_reader.arn
}
