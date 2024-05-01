
# LAMBDA FUNCTION FOR HTTP REQUESTS

resource "aws_lambda_function" "http_function" {
  filename         = "${path.root}/python/http_lambda.zip"
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
  source_dir  = "${path.root}/python/"
  output_path = "${path.root}/python/http_lambda.zip"
}
