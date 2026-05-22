# terraform {
#   backend "s3" {
#     bucket         = "team4-terraform-state"
#     key            = "vpc/terraform.tfstate"
#     region         = "ap-northeast-2"
#     dynamodb_table = "team4-terraform-lock"
#     encrypt        = true
#   }
# }
