provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region"
  type        = string
}

# Data source to check if the IAM role exists
data "aws_iam_role" "existing_lambda_role" {
  name = "lambda_role"
}

# IAM Role for Lambda, created only if it does not already exist
resource "aws_iam_role" "lambda_role" {
  count = data.aws_iam_role.existing_lambda_role.name != "" ? 0 : 1

  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

# Attach policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  count      = data.aws_iam_role.existing_lambda_role.name != "" ? 0 : 1
  role       = data.aws_iam_role.existing_lambda_role.name != "" ? data.aws_iam_role.existing_lambda_role.name : aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "api_lambda" {
  filename         = "${path.module}/bin/service.zip"
  function_name    = "api_lambda"
  role             = data.aws_iam_role.existing_lambda_role.name != "" ? data.aws_iam_role.existing_lambda_role.arn : aws_iam_role.lambda_role[0].arn
  handler          = "bootstrap"
  source_code_hash = filebase64sha256("${path.module}/bin/service.zip")
  runtime          = "provided.al2"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "ServiceAPI"
}

# API Resource
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "ping"
}

# API Method
resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Integration
resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id                = aws_api_gateway_rest_api.api.id
  resource_id                = aws_api_gateway_resource.api_resource.id
  http_method                = aws_api_gateway_method.api_method.http_method
  integration_http_method    = "POST"
  type                       = "AWS_PROXY"
  uri                        = aws_lambda_function.api_lambda.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.api_integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

# Output the API URL
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/prod/ping"
}
