
output "http_lambda_arn" {
  value       = aws_lambda_function.http_function.arn
  description = "value of the lambda function arn"
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
