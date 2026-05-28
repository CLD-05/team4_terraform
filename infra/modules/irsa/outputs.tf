output "alb_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA Role ARN"
  value       = aws_iam_role.alb_controller.arn
}

# output "diary_app_irsa_role_arn" {
#   description = "Diary App IRSA Role ARN"
#   value       = aws_iam_role.diary_app_irsa.arn
# }

# output "eks_oidc_provider_arn" {
#   description = "EKS OIDC Provider ARN for IRSA"
#   value       = aws_iam_openid_connect_provider.eks.arn
# }
