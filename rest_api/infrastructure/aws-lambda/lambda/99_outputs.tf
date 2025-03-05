output "lambda_function_invoke_url" {
  value = aws_lambda_function_url.terraform_lambda_func.function_url
}
