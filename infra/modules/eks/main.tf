locals {
  common_tags = {
    Project = var.cluster_name
    Team    = "team4"
  }
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.eks_node_sg_id]
    endpoint_private_access = true
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  tags = merge(local.common_tags, {
    Name = var.cluster_name
  })
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-node-group"
  })
}

# 팀원 kubectl 접근 권한 설정
resource "aws_eks_access_entry" "team" {
  count         = length(var.team_iam_users)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.team_iam_users[count.index]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "team" {
  count         = length(var.team_iam_users)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.team_iam_users[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
