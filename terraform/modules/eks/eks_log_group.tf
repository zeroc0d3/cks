resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.cluster_name}-eks/cluster"
  retention_in_days = var.eks.cloudwatch_retention_in_days
}
