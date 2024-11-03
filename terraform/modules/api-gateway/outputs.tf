output "api_gateway_invoke_url" {
    value = "${aws_apigatewayv2_api.name.api_endpoint}/${aws_apigatewayv2_stage.name.name}/${var.apigatewayv2_route}"
}