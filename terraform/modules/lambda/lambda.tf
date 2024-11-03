data "archive_file" "lambda" {
    type        = "zip"
    source_file = "./lambda_function.py"
    output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda_function" {
    filename         = data.archive_file.lambda.output_path
    function_name    = "${var.environment}-lambda-function-resize-image"
    role             = var.lambda_function_role_arn
    handler          = "lambda_function.lambda_handler"
    runtime          = "python3.11"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    timeout          = 30
    # https://api.klayers.cloud/api/v2/p3.11/layers/latest/us-east-1/html
    layers           = [ "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-Pillow:5" ]
}