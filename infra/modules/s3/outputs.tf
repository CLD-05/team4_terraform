output "bucket_name" {
  description = "이미지 저장 S3 버킷 이름"
  value       = aws_s3_bucket.diary_images.id
}

output "cloudfront_domain" {
  description = "CloudFront 도메인 주소"
  value       = aws_cloudfront_distribution.diary.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.diary.id
}

# output "bucket_arn" {
#   description = "이미지 저장 S3 버킷 ARN"
#   value       = aws_s3_bucket.diary_images.arn
# }
