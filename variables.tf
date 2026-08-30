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
  default = "1.31"
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

variable "lambda_authorizer_invoke_arn" {
  type    = string
  default = ""
}
