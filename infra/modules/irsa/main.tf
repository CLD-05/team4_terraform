locals {
  oidc_provider_host = replace(var.oidc_provider_url, "https://", "")
}

# EKS IRSA용 OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "eks" {
  url = var.oidc_provider_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da0ecd8d04f"
  ]
}

# AWS Load Balancer Controller용 IAM Role 생성
resource "aws_iam_role" "alb_controller" {
  name = "${var.project_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "${local.oidc_provider_host}:aud" = "sts.amazonaws.com"
          "${local.oidc_provider_host}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

# AWS Load Balancer Controller IAM Policy 생성
resource "aws_iam_policy" "alb_controller_policy" {
  name = "${var.project_name}-alb-controller-policy"

  policy = file("${path.module}/policies/alb-controller-policy.json")
}

# AWS Load Balancer Controller Role에 정책 연결
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

#Diary App Pod가 S3에 접근하기 위한 IRSA Role 생성
resource "aws_iam_role" "diary_app_irsa" {
  name = "${var.project_name}-diary-app-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      Condition = {
        StringEquals = {
          "${local.oidc_provider_host}:aud" = "sts.amazonaws.com"
        }

        StringLike = {
          "${local.oidc_provider_host}:sub" = [
            for namespace in var.app_namespaces :
            "system:serviceaccount:${namespace}:${var.app_service_account_name}"
          ]
        }
      }
    }]
  })
}

#Diary App S3 접근 정책 생성
resource "aws_iam_policy" "diary_app_s3_policy" {
  name = "${var.project_name}-diary-app-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = var.diary_bucket_arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${var.diary_bucket_arn}/*"
      }
    ]
  })
}

#Diary App IRSA Role에 S3 정책 연결
resource "aws_iam_role_policy_attachment" "diary_app_s3_attach" {
  role       = aws_iam_role.diary_app_irsa.name
  policy_arn = aws_iam_policy.diary_app_s3_policy.arn
}
