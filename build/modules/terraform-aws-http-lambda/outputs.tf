output "http_lambda_arn" {
  value       = aws_lambda_function.http-function.arn
  description = "value of the lambda function arn"
}

output "http_lambda_function_url" {
  value       = aws_lambda_function_url.http-function-url.function_url
  description = "value of the lambda function url"
}
