variable "environment" {
    type = string
}

variable "apigatewayv2_route" {
    type = string
    default = "resize-image"
}

variable "lambda_function_invoke_arn" {
    type = string
}

variable "lambda_function_name" {
    type = string
}