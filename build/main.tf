# Image Builder for Nginx HTTP Server


module "aws_public_networking" {
  source            = "./modules/terraform-aws-public-networking"
  availability_zone = var.availability_zone
}

module "aws_http_lambda" {
  source = "./modules/terraform-aws-http-lambda"
}

module "aws_logs_s3" {
  source           = "./modules/terraform-aws-logs-s3"
  logs_bucket_name = var.logs_bucket_name
}

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
      s3_bucket_name = module.aws_logs_s3.logs_bucket_name
      s3_key_prefix  = "logs"
    }
  }
}

# IAM ROLE FOR IMAGE BUILDER
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

  # inline policy for S3 bucket access to store logs
  inline_policy {
    name = "nginx_logs_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "s3:PutObject"
          Effect = "Allow"
          Resource = [
            module.aws_logs_s3.logs_bucket_arn,
            "${module.aws_logs_s3.logs_bucket_arn}/*",
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
