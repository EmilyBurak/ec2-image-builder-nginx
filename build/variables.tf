variable "availability_zone" {
  description = "The availability zone to deploy the resources in"
  type        = string
  default     = "us-west-2a"
}

variable "region" {
  description = "The region to deploy the resources in"
  type        = string
  default     = "us-west-2"
}

variable "logs_bucket_name" {
  description = "The name of the S3 bucket to store the Lambda logs"
  type        = string
  # default     = "nginx-http-logs"
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket to store the Terraform state file"
  type        = string
  # default     = "aws-http-lambda-state-west"

}

variable "state_table_name" {
  description = "The name of the DynamoDB table to store the Terraform state lock"
  type        = string
  default     = "http-lambda-locks"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = "dpp"
}
