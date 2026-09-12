variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "postech-tc3"
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.35"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_min" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 5
}

variable "node_desired" {
  type    = number
  default = 2
}

variable "lambda_issuer_invoke_arn" {
  type    = string
  default = ""
}

variable "lambda_issuer_function_name" {
  type    = string
  default = ""
}

variable "lambda_authorizer_invoke_arn" {
  type    = string
  default = ""
}

variable "lambda_authorizer_function_name" {
  type    = string
  default = ""
}

variable "app_backend_url" {
  type        = string
  default     = ""
  description = "URL publica do Service LoadBalancer da aplicacao, ex http://a1b2c3.elb.amazonaws.com"
}

variable "metrics_server_version" {
  type        = string
  default     = null
  description = "Versao do addon metrics-server; null usa a padrao da versao do cluster"
}

variable "vpc_cni_version" {
  type        = string
  default     = null
  description = "Versao do addon vpc-cni; null usa a padrao da versao do cluster"
}

variable "cluster_az_ids" {
  type        = list(string)
  default     = ["use1-az1", "use1-az2", "use1-az4", "use1-az5", "use1-az6"]
  description = "AZs das subnets do cluster; use1-az3 fica de fora porque o EKS nao aceita control plane nela"
}

variable "lab_eks_cluster_role_regex" {
  type    = string
  default = "LabEksClusterRole"
}

variable "lab_eks_node_role_regex" {
  type    = string
  default = "LabEksNodeRole"
}
