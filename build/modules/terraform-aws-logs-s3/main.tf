# S3 BUCKET FOR NGINX HTTP SERVER LOGS
resource "aws_s3_bucket" "nginx-http-logs" {
  bucket = var.logs_bucket_name

  # Prevent accidental deletion of S3 bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "enabled-logs-versioning" {
  bucket = aws_s3_bucket.nginx-http-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs-default" {
  bucket = aws_s3_bucket.nginx-http-logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-logs-public-access" {
  bucket                  = aws_s3_bucket.nginx-http-logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
