# Image Builder for Nginx HTTP Server

# IMAGE PIPELINE
resource "aws_imagebuilder_image_pipeline" "nginx-http" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.nginx-http.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.nginx-http.arn
  name                             = "nginx-http"
}

# IMAGE RECIPE
resource "aws_imagebuilder_image_recipe" "nginx-http" {
  block_device_mapping {
    device_name = "/dev/xvdb"

    ebs {
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp2"
    }
  }

  component {
    # build component
    component_arn = aws_imagebuilder_component.install_nginx.arn
  }
  component {
    # test component
    component_arn = aws_imagebuilder_component.invoke_http.arn
  }
  name = "nginx-http-tests"
  # Currently hardcoded to Amazon Linux 2023
  parent_image = "arn:aws:imagebuilder:us-west-2:aws:image/amazon-linux-2023-x86/x.x.x"
  version      = "1.0.0"
}

# BUILD COMPONENT
resource "aws_imagebuilder_component" "install_nginx" {
  data     = templatefile("${path.module}/components/install-nginx.yaml", {})
  name     = "install_nginx_http_component"
  platform = "Linux"
  version  = "1.0.0"
}

# TEST COMPONENT
resource "aws_imagebuilder_component" "invoke_http" {
  data     = templatefile("${path.module}/components/invoke-http-lambda.yaml", {})
  name     = "invoke_http_lambda_component"
  platform = "Linux"
  version  = "1.0.0"
}


module "aws_public_networking" {
  source            = "./modules/terraform-aws-public-networking"
  availability_zone = var.availability_zone
}

# IAM ROLE: Nginx HTTP Server and logs
resource "aws_iam_role" "nginx_http_role" {
  name                = "nginx_http_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder", "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com", "imagebuilder.amazonaws.com"]
        }
      },
    ]
  })

  inline_policy {
    name = "nginx_logs_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "s3:PutObject"
          Effect = "Allow"
          Resource = [
            aws_s3_bucket.nginx_http_logs.arn,
            "${aws_s3_bucket.nginx_http_logs.arn}/*",
          ]
        },
      ]
    })
  }

  tags = {
    Name = "nginx_http_role"
  }
}

resource "aws_iam_instance_profile" "nginx_http_profile" {
  name = "nginx_http_profile"
  role = aws_iam_role.nginx_http_role.name
}

# S3 BUCKET FOR NGINX HTTP SERVER LOGS
resource "aws_s3_bucket" "nginx_http_logs" {
  # placeholder development bucket name
  bucket = var.logs_bucket_name

  # Prevent accidental deletion of S3 bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "enabled_logs_versioning" {
  bucket = aws_s3_bucket.nginx_http_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_default" {
  bucket = aws_s3_bucket.nginx_http_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_logs_public_access" {
  bucket                  = aws_s3_bucket.nginx_http_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_imagebuilder_infrastructure_configuration" "nginx-http" {
  description                   = "nginx http server"
  instance_profile_name         = aws_iam_instance_profile.nginx_http_profile.name
  instance_types                = ["t3.micro"]
  key_pair                      = var.key_pair_name
  name                          = "nginx-http"
  security_group_ids            = [module.aws_public_networking.security_group_id]
  subnet_id                     = module.aws_public_networking.public_subnet_id
  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = aws_s3_bucket.nginx_http_logs.bucket
      s3_key_prefix  = "logs"
    }
  }
}

# LAMBDA FUNCTION FOR HTTP REQUESTS

# IAM ROLE

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "http_lambda" {
  name               = "httpt_lambda_servicerole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy_attachment" "lambda_basic_role_attach" {
  role       = aws_iam_role.http_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# could use a better CI/CD process for the lambda itself on S3 or ECR
# edit .py file locally and reupload for changes for now 
data "archive_file" "http_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/http_lambda.zip"
}


resource "aws_lambda_function" "http_function" {
  filename         = "${path.module}/python/http_lambda.zip"
  function_name    = "http_lambda_function"
  role             = aws_iam_role.http_lambda.arn
  runtime          = "python3.10"
  depends_on       = [aws_iam_role_policy_attachment.lambda_basic_role_attach]
  timeout          = 10 # increased as this can hit cold starts
  handler          = "server-call-lambda.lambda_handler"
  source_code_hash = data.archive_file.http_lambda_zip.output_base64sha256
  layers           = [data.klayers_package_latest_version.requests.arn]
}

# Needed for the requests library in the lambda function after AWS removed it
data "klayers_package_latest_version" "requests" {
  name   = "requests"
  region = "us-west-2"
}

# Sets up endpoint for the lambda function to be accessed in testing 
resource "aws_lambda_function_url" "http_function_url" {
  function_name      = aws_lambda_function.http_function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
  }
}
