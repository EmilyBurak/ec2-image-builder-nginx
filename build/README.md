<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_klayers"></a> [klayers](#requirement\_klayers) | ~> 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.47.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_http_lambda"></a> [aws\_http\_lambda](#module\_aws\_http\_lambda) | ./modules/terraform-aws-http-lambda | n/a |
| <a name="module_aws_http_sg"></a> [aws\_http\_sg](#module\_aws\_http\_sg) | terraform-aws-modules/security-group/aws//modules/http-80 | n/a |
| <a name="module_aws_logs_s3"></a> [aws\_logs\_s3](#module\_aws\_logs\_s3) | ./modules/terraform-aws-logs-s3 | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.nginx-http-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.nginx-http-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_imagebuilder_component.install-nginx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |
| [aws_imagebuilder_component.invoke-http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_component) | resource |
| [aws_imagebuilder_image_pipeline.nginx-http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) | resource |
| [aws_imagebuilder_image_recipe.nginx-http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_recipe) | resource |
| [aws_imagebuilder_infrastructure_configuration.nginx-http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_infrastructure_configuration) | resource |
| [aws_sns_topic.image-builder-result](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.sns-topic-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.amzn2023-ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The availability zone to deploy the resources in | `string` | n/a | yes |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | The name of the S3 bucket to store the Lambda logs | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_lambda_arn"></a> [http\_lambda\_arn](#output\_http\_lambda\_arn) | value of the lambda function arn |
| <a name="output_http_lambda_function_url"></a> [http\_lambda\_function\_url](#output\_http\_lambda\_function\_url) | value of the lambda function url |
| <a name="output_logs_bucket_arn"></a> [logs\_bucket\_arn](#output\_logs\_bucket\_arn) | value of the s3 logs bucket arn |
| <a name="output_nginx_pipeline_arn"></a> [nginx\_pipeline\_arn](#output\_nginx\_pipeline\_arn) | value of the image pipeline arn |
| <a name="output_nginx_recipe_name"></a> [nginx\_recipe\_name](#output\_nginx\_recipe\_name) | value of the image recipe name |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | value of the public subnet id |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | value of the security group id |
<!-- END_TF_DOCS -->