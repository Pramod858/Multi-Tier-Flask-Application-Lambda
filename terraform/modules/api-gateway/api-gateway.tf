resource "aws_apigatewayv2_api" "name" {
    name          = "${var.environment}-api-gateway"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "name" {
    api_id      = aws_apigatewayv2_api.name.id
    name        = "test"
    auto_deploy = true
}

resource "aws_apigatewayv2_integration" "name" {
    api_id                 = aws_apigatewayv2_api.name.id
    integration_type       = "AWS_PROXY"
    integration_method     = "POST"
    integration_uri        = var.lambda_function_invoke_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post" {
    api_id    = aws_apigatewayv2_api.name.id
    route_key = "POST /${var.apigatewayv2_route}"
    target    = "integrations/${aws_apigatewayv2_integration.name.id}"
}

#deploy api gateway
resource "aws_lambda_permission" "name" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = var.lambda_function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.name.execution_arn}/*/*"
}