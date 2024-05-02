# AWS HTTP Lambda

This module provisions a Lambda function meant to use `requests` in Python to query a given endpoint whiel passing a specific user-agent string for identifying the call in logs. This function is set up behind a public function URL with CORS configuration. A basic IAM role is created with a policy to allow Lambda to assume and execute using the role. Finally, deployment is handled via. checking the `/build/python` directory for an updated `server-call-lambda.py`, zipping it and uploading it to Lambda.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_klayers"></a> [klayers](#requirement\_klayers) | ~> 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_klayers"></a> [klayers](#provider\_klayers) | ~> 1.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.http_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_role_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.http-function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.http-function-url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [archive_file.http_lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [klayers_package_latest_version.requests](https://registry.terraform.io/providers/ldcorentin/klayer/latest/docs/data-sources/package_latest_version) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_lambda_arn"></a> [http\_lambda\_arn](#output\_http\_lambda\_arn) | value of the lambda function arn |
| <a name="output_http_lambda_function_url"></a> [http\_lambda\_function\_url](#output\_http\_lambda\_function\_url) | value of the lambda function url |
<!-- END_TF_DOCS -->