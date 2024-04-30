
output "http_lambda_arn" {
  value = aws_lambda_function.http_function.arn
}

output "nginx_pipeline_id" {
  value = aws_imagebuilder_image_pipeline.nginx-http.id
}
