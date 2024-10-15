terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}

provider "aws" {

  region = "us-east-2"
  profile = "caro-prueba"
}

resource "aws_iam_user" "lb" {
  name = "developer"

  tags = {
   "env" = "developer"
   "app" = "tag-test-credibanco"
  }
}

resource "aws_iam_policy" "policy_logs_lambda" {
  name        = "policy_logs_lambda"
  path        = "/"
  description = "AWS policy for lambda function"

  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "dynamodb:*",
        ]
        Effect   = "Allow"
        Resource = [
            "arn:aws:logs:*:*:*",
            "arn:aws:dynamodb:*:*:*"
        ]
        

      },
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_function_role"
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

  filename      = "./python/index1.py.zip"
  function_name = "lambda_function_test"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime = "python3.8"

}
