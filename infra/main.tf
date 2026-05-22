module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}


# EKS가 없으므로 임시로 OIDC Provider를 루트에 선언해 공급합니다.
resource "aws_iam_openid_connect_provider" "mock_eks" {
  url             = "https://oidc.eks.ap-northeast-2.amazonaws.com/id/EXAMPLERANDOM12345"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b143cc6f77ec1a648b7ff485625e"]
}

# iam 모듈 호출
module "iam" {
  source            = "./modules/iam"
  project_name      = var.project_name
  oidc_provider_arn = aws_iam_openid_connect_provider.mock_eks.arn
  oidc_provider_url = aws_iam_openid_connect_provider.mock_eks.url
}
