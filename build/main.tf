# Image Builder for Nginx HTTP Server

module "aws_http_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "nginx-http-sg"
  description = "Security group for nginx EC2 Image Builder testing with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

}

module "aws_http_lambda" {
  source = "./modules/terraform-aws-http-lambda"
}

module "aws_logs_s3" {
  source           = "./modules/terraform-aws-logs-s3"
  logs_bucket_name = var.logs_bucket_name
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nginx-http-vpc"
  cidr = "10.0.0.0/16"

  azs                     = [var.availability_zone]
  public_subnets          = ["10.0.1.0/24"]
  map_public_ip_on_launch = true
}

# IMAGE PIPELINE
resource "aws_imagebuilder_image_pipeline" "nginx-http" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.nginx-http.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.nginx-http.arn
  name                             = "nginx-http"

}

# Most recent Amazon Linux 2023 AMI
data "aws_ssm_parameter" "amzn2023-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
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
    component_arn = aws_imagebuilder_component.install-nginx.arn
  }
  component {
    # test component
    component_arn = aws_imagebuilder_component.invoke-http.arn
  }
  name         = "nginx-http-tests"
  parent_image = data.aws_ssm_parameter.amzn2023-ami.value
  version      = "1.0.0"
}

# BUILD COMPONENT
resource "aws_imagebuilder_component" "install-nginx" {
  data     = templatefile("${path.module}/components/install-nginx.yaml", {})
  name     = "install_nginx_http_component"
  platform = "Linux"
  version  = "1.0.0"
}

# TEST COMPONENT
resource "aws_imagebuilder_component" "invoke-http" {
  data     = templatefile("${path.module}/components/invoke-http-lambda.yaml", { function_invoke_url = module.aws_http_lambda.http_lambda_function_url })
  name     = "invoke_http_lambda_component"
  platform = "Linux"
  version  = "1.0.0"
}

resource "aws_imagebuilder_infrastructure_configuration" "nginx-http" {
  description                   = "nginx http server"
  instance_profile_name         = aws_iam_instance_profile.nginx-http-profile.name
  instance_types                = ["t3.micro"]
  name                          = "nginx-http"
  security_group_ids            = [module.aws_http_sg.security_group_id]
  subnet_id                     = module.vpc.public_subnets[0]
  terminate_instance_on_failure = true
  sns_topic_arn                 = aws_sns_topic.image-builder-result.arn

  logging {
    s3_logs {
      s3_bucket_name = module.aws_logs_s3.logs_bucket_name
      s3_key_prefix  = "logs"
    }
  }
}

# IAM ROLE FOR IMAGE BUILDER
resource "aws_iam_role" "nginx-http-role" {
  name                = "nginx-http-role"
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
    Name = "nginx-http-role"
  }
}

resource "aws_iam_instance_profile" "nginx-http-profile" {
  name = "nginx-http-profile"
  role = aws_iam_role.nginx-http-role.name
}

resource "aws_sns_topic" "image-builder-result" {
  name = "nginx-http-image-builder-result"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.image-builder-result.arn
  policy = data.aws_iam_policy_document.sns-topic-policy.json
}

data "aws_iam_policy_document" "sns-topic-policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.image-builder-result.arn]
  }
}

