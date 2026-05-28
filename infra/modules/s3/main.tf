# 이미지 저장용 S3 버킷
resource "aws_s3_bucket" "diary_images" {
  bucket = "${var.project_name}-diary-images"

  tags = {
    Name = "${var.project_name}-diary-images"
    team = "team4"
  }
}

# 퍼블릭 액세스 차단 (CloudFront로만 접근)
resource "aws_s3_bucket_public_access_block" "diary_images" {
  bucket = aws_s3_bucket.diary_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "diary" {
  name                              = "${var.project_name}-diary-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "diary" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.diary_images.bucket_regional_domain_name
    origin_id                = "S3-${var.project_name}-diary-images"
    origin_access_control_id = aws_cloudfront_origin_access_control.diary.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.project_name}-diary-images"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-diary-cf"
    team = "team4"
  }
}

# S3 버킷 정책 (CloudFront에서만 접근 허용)
resource "aws_s3_bucket_policy" "diary_images" {
  bucket = aws_s3_bucket.diary_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.diary_images.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.diary.arn
        }
      }
    }]
  })
}
