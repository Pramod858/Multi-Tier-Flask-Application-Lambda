resource "aws_api_gateway_domain_name" "custom_domain" {
    domain_name              = var.custom_domain_name
    security_policy          = "TLS_1_2" 
    regional_certificate_arn = var.custom_domain_cert_arn

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

# Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "mapping" {
    api_id      = aws_apigatewayv2_api.name.id
    stage_name  = aws_apigatewayv2_stage.name.name
    domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
}