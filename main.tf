provider "aws" {
  region = "us-east-1"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

# AWS Lambda function
resource "aws_lambda_function" "flask_lambda" {
  function_name = "flask_lambda"
  handler       = "hello-world/app.lambdaHandler" 
  runtime       = "nodejs16.x"
  role          = aws_iam_role.lambda_role.arn
  filename      = "my_lambda.zip" 

  source_code_hash = filebase64sha256("my_lambda.zip")

  environment {
    variables = {
      FLASK_ENV = "production"
    }
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.flask_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.flask_deployment.execution_arn}/*/*"
#   source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}




# V1 API Gateway 
# V1 API Gateway 
# V1 API Gateway 
# V1 API Gateway 
# # API Gateway configuration
resource "aws_api_gateway_rest_api" "flask_api" {
  name        = "flask_api"
  description = "API for Flask App"
}

resource "aws_api_gateway_resource" "flask_resource" {
  rest_api_id = aws_api_gateway_rest_api.flask_api.id
  parent_id   = aws_api_gateway_rest_api.flask_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.flask_api.id
  resource_id   = aws_api_gateway_resource.flask_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.flask_api.id
  resource_id = aws_api_gateway_resource.flask_resource.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.flask_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "flask_deployment" {
  depends_on = [aws_api_gateway_integration.lambda]

  rest_api_id = aws_api_gateway_rest_api.flask_api.id
  stage_name  = "prod"
}

output "api_url" {
  value = aws_api_gateway_deployment.flask_deployment.invoke_url
}



# V2 API Gateway 
# V2 API Gateway 
# V2 API Gateway 
# V2 API Gateway 

# resource "aws_apigatewayv2_api" "lambda" {
#   name          = "serverless_lambda_gw"
#   protocol_type = "HTTP"
# }

# resource "aws_apigatewayv2_stage" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   name        = "$default" # https://stackoverflow.com/questions/66977149/how-can-i-create-a-default-deployment-stage-in-api-gateway-using-terraform
# #   name        = "serverless_lambda_stage" # output = https://g2fv75e0s0....com/serverless_lambda_stage
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_gw.arn

#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }
# }

# resource "aws_apigatewayv2_integration" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   integration_uri    = aws_lambda_function.flask_lambda.invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
# }

# resource "aws_apigatewayv2_route" "hello_world" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   route_key = "GET /hello"
#   target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
# }

# resource "aws_cloudwatch_log_group" "api_gw" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

#   retention_in_days = 30
# }

# output "base_url" {
#   description = "Base URL for API Gateway stage."

#   value = aws_apigatewayv2_stage.lambda.invoke_url
# }

