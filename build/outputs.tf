
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

output "nginx_pipeline_arn" {
  value       = aws_imagebuilder_image_pipeline.nginx-http.arn
  description = "value of the image pipeline arn"
}

output "nginx_recipe_name" {
  value       = aws_imagebuilder_image_recipe.nginx-http.name
  description = "value of the image recipe name"
}

output "public_subnet_id" {
  value       = module.vpc.public_subnets[0]
  description = "value of the public subnet id"
}

output "security_group_id" {
  value       = module.aws_http_sg.security_group_id
  description = "value of the security group id"
}
