output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_gateway_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "api_gateway_routes" {
  value = {
    emitir_token  = "POST ${aws_apigatewayv2_api.this.api_endpoint}/auth"
    rotas_abertas = "GET /{proxy+} e POST /api/v1/auth/{proxy+}"
    rotas_regidas = "ANY /api/v1/{proxy+} (authorizer ${local.authorizer_enabled ? "ativo" : "desligado"})"
  }
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
