# Create the API Gateway HTTP API
resource "aws_apigatewayv2_api" "visitor_count_api" {
  name          = "VisitorCountAPI"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age = 300
  }
}

# Create 2 Stages: default and dev
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.visitor_count_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_stage" "visitor_count_stage" {
  api_id      = aws_apigatewayv2_api.visitor_count_api.id
  name        = "dev"
  auto_deploy = true
}

# Create an Integration with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.visitor_count_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_count_function.invoke_arn
  integration_method = "POST"

  payload_format_version = "1.0"
}

# Create a default route for the API Gateway
resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.visitor_count_api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_count_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_count_api.execution_arn}/*/*"
}

# resource "aws_apigatewayv2_integration_response" "default_integration_response" {
#   api_id            = aws_apigatewayv2_api.visitor_count_api.id
#   integration_id    = aws_apigatewayv2_integration.lambda_integration.id
#   integration_response_key = "$default"

#   response_templates = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
#     "method.response.header.Access-Control-Allow-Origin" = "'*'"
#   }
# }

# resource "aws_apigatewayv2_route_response" "default_route_response" {
#   api_id              = aws_apigatewayv2_api.visitor_count_api.id
#   route_id            = aws_apigatewayv2_route.proxy_route.id
#   route_response_key  = "$default"

#   response_models = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
#     "method.response.header.Access-Control-Allow-Origin" = "'*'"
#   }
# }