terraform {
    backend "s3" {
        bucket = "pramod858tf"
        key    = "terraform/flask-lambda-app/terraform.tfstate"
        region = "us-east-1"
    }
}