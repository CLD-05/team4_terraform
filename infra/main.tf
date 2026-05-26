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
