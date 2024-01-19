variable "lambda_subnet_ids" {
  description = "List of subnet IDs"
}

variable "lambda_security_group_id" {
  description = "Security Group ID for Lambda"
}

variable "rds_endpoint_for_lambda" {
  description = "Endpoint for connecting RDS with Lambda"
}

variable "ec_endpoint_ip" {
  description = "IP address for connecting ElastiCache with Lambda"
}

variable "ec_endpoint_port" {
  description = "Port address for connecting ElastiCache with Lambda"
}

resource "aws_iam_role" "lambda_role" {
  name = "Spacelift_Test_Lambda_Function_Role"

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
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" { 
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "ec2:DescribeNetworkInterfaces",
       "ec2:DescribeInstances",
       "ec2:DescribeSecurityGroups",
       "ec2:DescribeSubnets",
       "ec2:CreateNetworkInterface",
       "ec2:DeleteNetworkInterface",
       "rds-db:connect",
       "rds:DescribeDBInstances",
       "rds:DescribeDBClusters",
       "rds:DescribeDBLogFiles",
       "rds:DownloadDBLogFilePortion"
     ],
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "lambda_zipped_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../../code/src/"
  output_path = "${path.module}/../../../code/build.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = data.archive_file.lambda_zipped_code.output_path
  function_name    = "Spacelift_Test_Lambda_Function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_zipped_code.output_md5

  environment {
    variables = {
      JWT_EXPIRATION_MINUTES = 125
      JWT_SECRET  = "secret"
      JWT_ALGORITHM = "HS256"
      DB_ENDPOINT = var.rds_endpoint_for_lambda
      DB_NAME     = "test_db"
      DB_USER     = "postgres"
      DB_PASSWORD = "password"
      REDIS_IP    = var.ec_endpoint_ip
      REDIS_PORT  = var.ec_endpoint_port
    }
  }

  vpc_config {
    subnet_ids = var.lambda_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  layers = [aws_lambda_layer_version.lib_layer1.arn, aws_lambda_layer_version.lib_layer2.arn]
  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}


resource "aws_lambda_layer_version" "lib_layer1" {
  filename   = "${path.module}/../../../code/libraries/libraries_part1.zip"
  layer_name = "lambda_libraries_layer_1"
  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_layer_version" "lib_layer2" {
  filename   = "${path.module}/../../../code/libraries/libraries_part2.zip"
  layer_name = "lambda_libraries_layer_2"
  compatible_runtimes = ["python3.8"]
}


resource "aws_lambda_function_url" "terraform_lambda_func" {
  function_name      = aws_lambda_function.terraform_lambda_func.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["date", "keep-alive"]
    max_age           = 86400
  }
}

output "lambda_function_invoke_url" {
  value = aws_lambda_function_url.terraform_lambda_func.function_url
}
