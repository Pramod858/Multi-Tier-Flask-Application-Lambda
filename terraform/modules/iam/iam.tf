resource "aws_iam_role" "ecsTaskExecutionRole" {
    name               = "${var.environment}-ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version        = "2012-10-17"
        
        Statement = [
        {
            Effect    = "Allow"
            Principal = {
                Service   = "ecs-tasks.amazonaws.com"
            }
            Action    = "sts:AssumeRole"
        }
        ]
    })
}

resource "aws_iam_role_policy_attachments_exclusive" "example" {
    role_name   = aws_iam_role.ecsTaskExecutionRole.name
    policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}


resource "aws_iam_role" "ecsTaskRole" {
    name               = "${var.environment}-ecsTaskRole"
    assume_role_policy = jsonencode({
        Version        = "2012-10-17"
        
        Statement = [
        {
            Effect    = "Allow"
            Principal = {
                Service   = "ecs-tasks.amazonaws.com"
            }
            Action    = "sts:AssumeRole"
        }
        ]
    })
}
resource "aws_iam_role_policy" "s3_bucket_ecs" {
    name   = "${var.environment}-s3-bucket-policy-ecs"
    role   = aws_iam_role.ecsTaskRole.name
    policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::${var.source_bucket}/*"
			]
		}
	]
}
EOF
}

resource "aws_iam_role" "lambda_function_role" {
    name               = "${var.environment}-lambda-function-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "MyLambdaRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
    role       = aws_iam_role.lambda_function_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

resource "aws_iam_role_policy" "s3_bucket_lambda" {
    name   = "${var.environment}-s3-bucket-policy-lambda"
    role   = aws_iam_role.lambda_function_role.name
    policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject"
			],
			"Resource": [
				"arn:aws:s3:::${var.source_bucket}/*"
			]
		},
		{
			"Sid": "Statement2",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::${var.target_bucket}/*"
			]
		}
	]
}
EOF
}