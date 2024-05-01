output "http_lambda_arn" {
  value       = aws_lambda_function.http_function.arn
  description = "value of the lambda function arn"
}

output "http_lambda_function_url" {
  value       = aws_lambda_function_url.http_function_url.function_url
  description = "value of the lambda function url"
}
