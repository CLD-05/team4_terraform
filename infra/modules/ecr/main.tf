resource "aws_ecr_repository" "backend_api" {
  name                 = "team4-backend-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}