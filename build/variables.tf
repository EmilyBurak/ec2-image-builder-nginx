variable "availability_zone" {
  description = "The availability zone to deploy the resources in"
  type        = string
}

variable "logs_bucket_name" {
  description = "The name of the S3 bucket to store the Lambda logs"
  type        = string
}

# variable "state_bucket_name" {
#   description = "The name of the S3 bucket to store the Terraform state file"
#   type        = string
#   default     = "aws-http-lambda-state-west"
# }

# variable "state_table_name" {
#   description = "The name of the DynamoDB table to store the Terraform state lock"
#   type        = string
#   default     = "http-lambda-locks"
# }
