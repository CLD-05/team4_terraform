module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "ecr" {
  source = "./modules/ecr"
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.db_subnet_ids
  db_password        = var.db_password
  rds_sg_id          = "sg-0f9a25eb58ef2b1b8"
}

module "backend" {
  source       = "./modules/backend"
  project_name = var.project_name
}

module "iam" {
  source            = "./modules/iam"
  project_name      = var.project_name
  github_repo       = "CLD-05/team4_terraform"
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "${var.project_name}-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id     = module.vpc.eks_node_sg_id
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  team_iam_users = [
    "arn:aws:iam::194722398200:user/team4-ksc",
    "arn:aws:iam::194722398200:user/team4-lsh",
    "arn:aws:iam::194722398200:user/team4-cmk",
    "arn:aws:iam::194722398200:user/team4-kwh",
    "arn:aws:iam::194722398200:user/team4-ldj",
    "arn:aws:iam::194722398200:user/team4-ljh",
    "arn:aws:iam::194722398200:user/team4-h",
  ]
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}
