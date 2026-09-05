resource "aws_eks_addon" "metrics_server" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "metrics-server"
  addon_version = var.metrics_server_version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.tags
}
