
output "http_lambda_arn" {
  value       = module.aws_http_lambda.http_lambda_arn
  description = "value of the lambda function arn"
}

output "http_lambda_function_url" {
  value       = module.aws_http_lambda.http_lambda_function_url
  description = "value of the lambda function url"
}

output "logs_bucket_arn" {
  value       = module.aws_logs_s3.logs_bucket_arn
  description = "value of the s3 logs bucket arn"

}

output "nginx_pipeline_id" {
  value       = aws_imagebuilder_image_pipeline.nginx-http.id
  description = "value of the image pipeline id"
}

output "public_subnet_id" {
  value       = module.aws_public_networking.public_subnet_id
  description = "value of the public subnet id"
}

output "security_group_id" {
  value       = module.aws_public_networking.security_group_id
  description = "value of the security group id"
}
