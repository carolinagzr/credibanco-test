# Crear el API Gateway
resource "aws_apigatewayv2_api" "my_api" {
  name          = "MyApiGateway"
  protocol_type = "HTTP"
}

# Crear la integración entre el API Gateway y Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.my_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.test_lambda.arn
  payload_format_version = "2.0"
}

# Crear la ruta en el API Gateway para invocar la Lambda
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.my_api.id
  route_key = "POST /crear-orden"  # Método y path para acceder a la Lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "lambda_route_nequi" {
  api_id    = aws_apigatewayv2_api.my_api.id
  route_key = "POST /webhook-nequi"  # Método y path para acceder a la Lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
# Crear la etapa de despliegue para el API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.my_api.id
  name        = "$default"
  auto_deploy = true
}

# Dar permisos a API Gateway para invocar la función Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.my_api.execution_arn}/*"
}
