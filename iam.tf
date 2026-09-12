data "aws_iam_roles" "eks_cluster" {
  name_regex = var.lab_eks_cluster_role_regex
}

data "aws_iam_roles" "eks_node" {
  name_regex = var.lab_eks_node_role_regex
}
