terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.71.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
  profile = "caro-prueba"
}
#new-user
resource "aws_iam_user" "lb" {
  name = "developer"

  tags = {
   "env" = "developer"
   "app" = "tag-test-credibanco"
  }
}
#Policy
resource "aws_iam_policy" "policy_logs_lambda" {
  name        = "policy_logs_lambda"
  path        = "/"
  description = "AWS policy for lambda function"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"

      },
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_function_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
   "app" = "tag-test-credibanco"
  }
}
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy_logs_lambda.arn
}
resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "./python/index1.py.zip"
  function_name = "lambda_function_test"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime = "python3.8"

}