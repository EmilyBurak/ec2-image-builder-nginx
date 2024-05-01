output "logs_bucket_arn" {
  value       = aws_s3_bucket.nginx_http_logs.arn
  description = "value of the s3 bucket arn"
}

output "logs_bucket_name" {
  value       = aws_s3_bucket.nginx_http_logs.bucket
  description = "value of the logs bucket name"
}
