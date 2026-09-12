environment        = "prod"
vpc_id             = "vpc-05abad32762eabfe1"
node_instance_type = "t3.medium"
node_min           = 2
node_max           = 5
node_desired       = 2

lambda_issuer_invoke_arn        = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:875283173120:function:postech-tc3-prod-auth-issuer/invocations"
lambda_issuer_function_name     = "postech-tc3-prod-auth-issuer"
lambda_authorizer_invoke_arn    = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:875283173120:function:postech-tc3-prod-auth-authorizer/invocations"
lambda_authorizer_function_name = "postech-tc3-prod-auth-authorizer"
app_backend_url                 = "http://a9d3c6e66f7774faf88c245d360ae140-a15c8e436ac2f1e3.elb.us-east-1.amazonaws.com"
