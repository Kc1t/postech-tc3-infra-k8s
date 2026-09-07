locals {
  authorizer_enabled = var.lambda_authorizer_invoke_arn != ""
  issuer_enabled     = var.lambda_issuer_invoke_arn != ""
  backend_enabled    = var.app_backend_url != ""
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${local.name}-gateway"
  protocol_type = "HTTP"

  tags = local.tags
}

# tfsec:ignore:aws-cloudwatch-log-group-customer-key O Learner Lab nao permite criar CMK; o log fica com a chave gerenciada da AWS.
resource "aws_cloudwatch_log_group" "gateway" {
  name              = "/aws/apigateway/${local.name}"
  retention_in_days = 14

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.gateway.arn
    format = jsonencode({
      correlationId  = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      latency        = "$context.responseLatency"
      authorizer     = "$context.authorizer.error"
    })
  }

  default_route_settings {
    throttling_burst_limit = 200
    throttling_rate_limit  = 100
  }

  tags = local.tags
}

resource "aws_apigatewayv2_authorizer" "cpf" {
  count = local.authorizer_enabled ? 1 : 0

  api_id                            = aws_apigatewayv2_api.this.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.lambda_authorizer_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  authorizer_result_ttl_in_seconds  = 0
  identity_sources                  = ["$request.header.Authorization"]
  name                              = "${local.name}-cpf-authorizer"
}

resource "aws_lambda_permission" "authorizer" {
  count = local.authorizer_enabled ? 1 : 0

  statement_id  = "AllowInvocationFromApiGatewayAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_authorizer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.cpf[0].id}"
}

resource "aws_apigatewayv2_integration" "issuer" {
  count = local.issuer_enabled ? 1 : 0

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_issuer_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "issuer" {
  count = local.issuer_enabled ? 1 : 0

  statement_id  = "AllowInvocationFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_issuer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "auth" {
  count = local.issuer_enabled ? 1 : 0

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.issuer[0].id}"
}

resource "aws_apigatewayv2_integration" "app" {
  count = local.backend_enabled ? 1 : 0

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = "${var.app_backend_url}/{proxy}"
}

resource "aws_apigatewayv2_route" "app_health" {
  count = local.backend_enabled ? 1 : 0

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.app[0].id}"
}

resource "aws_apigatewayv2_route" "app_public_auth" {
  count = local.backend_enabled ? 1 : 0

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /api/v1/auth/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.app[0].id}"
}

resource "aws_apigatewayv2_route" "app_protected" {
  count = local.backend_enabled ? 1 : 0

  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "ANY /api/v1/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.app[0].id}"
  authorization_type = local.authorizer_enabled ? "CUSTOM" : "NONE"
  authorizer_id      = local.authorizer_enabled ? aws_apigatewayv2_authorizer.cpf[0].id : null
}
