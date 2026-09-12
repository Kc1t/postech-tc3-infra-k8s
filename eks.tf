# Endpoint publico: os runners do GitHub Actions rodam fora da VPC e nao ha NAT nem VPN neste desenho.
# Restringir por CIDR nao ajuda, as faixas dos runners sao dinamicas.
#
# Recursos nativos em vez do modulo terraform-aws-modules/eks: o modulo chama iam:GetRole na role da
# sessao, que o Learner Lab nega, e cria roles IAM e chave KMS, que o lab tambem nao permite. O cluster e
# os nos usam as roles que o lab ja entrega, e os secrets do cluster ficam sem criptografia por CMK.
#
# tfsec:ignore:aws-eks-no-public-cluster-access
# tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
# tfsec:ignore:aws-eks-encrypt-secrets
resource "aws_eks_cluster" "this" {
  name     = local.name
  version  = var.cluster_version
  role_arn = one(data.aws_iam_roles.eks_cluster.arns)

  vpc_config {
    subnet_ids              = data.aws_subnets.default.ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_cloudwatch_log_group.cluster]

  tags = local.tags
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key O Learner Lab nao permite criar CMK; o log fica com a chave gerenciada da AWS.
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.name}/cluster"
  retention_in_days = 14

  tags = local.tags
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "workers"
  node_role_arn   = one(data.aws_iam_roles.eks_node.arns)
  subnet_ids      = data.aws_subnets.default.ids

  instance_types = [var.node_instance_type]
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 20

  scaling_config {
    min_size     = var.node_min
    max_size     = var.node_max
    desired_size = var.node_desired
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = local.tags
}
