resource "aws_eks_cluster" "this" {
  name = var.eks.name
  enabled_cluster_log_types = var.eks.enabled_cluster_log_types

# CREATE
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks.version

  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }

  access_config {
    authentication_mode = var.eks.access_config_authentication_mode
  }

  depends_on = [
  aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
]

}
