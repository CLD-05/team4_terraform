output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

# EKS 생성 후 활성화
# output "alb_controller_role_arn" {
#   value = aws_iam_role.alb_controller.arn
# }

# output "github_actions_role_arn" {
#   value = aws_iam_role.github_actions.arn
# }
