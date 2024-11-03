output "ecsTaskExecutionRole_arn" {
    value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "ecsTaskRole_arn" {
    value = aws_iam_role.ecsTaskRole.arn
}

output "lambda_function_role_arn" {
    value = aws_iam_role.lambda_function_role.arn
}