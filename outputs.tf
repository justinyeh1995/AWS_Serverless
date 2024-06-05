# Input variable definitions

output "base_url" {
  description = "Base URL for API Gateway stage."
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}