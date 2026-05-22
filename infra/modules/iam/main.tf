data "aws_caller_identity" "current" {}

locals {
  # OIDC URL에서 "https://"를 제거해야만 AssumeRole 백엔드 조건절이 정상 작동합니다.
  oidc_url_stripped = replace(var.oidc_provider_url, "https://", "")
}

# 1. IRSA 검증용 테스트 S3 버킷 생성
resource "aws_s3_bucket" "irsa_test" {
  bucket        = "${var.project_name}-irsa-test-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-irsa-test"
  }
}

# 2. 테스트 버킷 내 실습용 파일 업로드
resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.irsa_test.bucket
  key     = "hello.txt"
  content = "IRSA 정상 동작 확인!"
}

# 3. EKS Pod 전용 IAM Role (IRSA) 생성
resource "aws_iam_role" "s3_reader" {
  name = "${var.project_name}-s3-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_url_stripped}:aud" = "sts.amazonaws.com"
          # 쿠버네티스의 default 네임스페이스 내 s3-reader-sa 서비스 어카운트에 권한 매핑
          "${local.oidc_url_stripped}:sub" = "system:serviceaccount:default:s3-reader-sa"
        }
      }
    }]
  })
}

# 4. IAM Role에 S3 읽기 전용 AWS 관리형 정책 연결
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.s3_reader.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
