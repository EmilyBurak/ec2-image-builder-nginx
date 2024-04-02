# ec2-image-builder-nginx Resources

This repository contains resources for [EC2 Image Builder](https://aws.amazon.com/image-builder/), including YAML components running bash scripts that can be used in a pipeline to install and test nginx by calling a Lambda that cURLs the Image Builder test instance to confirm nginx is working.

## install-nginx.yaml

The `install-nginx.yaml` component is a Build stage component in bash for EC2 Image Builder that installs nginx as part of the EC2 Image Builder pipeline on an AWS 2023 Linux x86 instance(I haven't tested it on other setups), listening on port 80 and logging to the `access_log`. It can be used to configure and set up nginx on EC2 instances.

## server-call-lambda.py

The `server-call-lambda.py` script is a Lambda function written in Python. It uses the `subprocess` library to make a cURL request to a given server, in this case given during pipeline execution's Test stage. It passes the user agent string so that the request can be `grep`'d for in the logs to confirm its existence.

## invoke-http-lambda.yaml

The `invoke-http-lambda.yaml` component is a Test stage component in bash that invokes the `server-call-lambda.py` Lambda function as part of the EC2 Image Builder pipeline, passing the public IP of the test instance to be called back by the Lambda(to test accessing the server remotely) and then looks with `grep` in the `access_log` for the resultant cURL from the Lambda identified by the user agent string.

Please refer to the individual script/configuration files for more details. Hopefully they're demonstrative and 'self-documenting' where I haven't left comments.

# Setup

You'll need:

- A Lambda off of `server-call-lambda.py` with a function URL that you'll substitute into the code of `invoke-http-lambda.yaml` when you use it with CORS setup to receive GET requests.
- An EC2 Image Builder Pipeline including:
  - The Build component of `install-nginx.yaml` that installs nginx and configures it.
  - The Test component for the pipeline to invoke the Lambda contained in `invoke-http-lambda.yaml`.
- A security group allowing port 80 for nginx set up within a VPC with a subnet with `auto-assign public ip` on to be used in the infrastructure configuration of the pipeline.
- An IAM role with the appropriate policies to be used in the pipeline infrastructure configuration:
  - `EC2InstanceProfileForImageBuilder`
  - `AmazonSSMManagedInstanceCore`
    - Otherwise you'd be stuck using the default role which in the UI at least won't let you select a custom VPC and security group and everything will get gunked up and it's just not a great time.

# Future Work

- Would like to put the Image Builder resources into Terraform instead of needing an initial manual configuration.
- The code for the lambda itself is clunky, I switched from `requests` partway through, and needing a regex to cURL the right address using a public function url is ugly.
  - I'd rather call it with the AWS CLI and set up authentication properly.
- Better error handling in the bash and better validation of the received nginx request from the lambda, generally make the output more verbose and demonstrative of what is happening in the Test component.

# Resources

- https://www.shellcheck.net/ (really cool bug checker for shell scripts that got me past some syntax errors.)
- https://spin.atomicobject.com/jq-creating-updating-json/ (I hadn't used jq much, especially to create JSON, so this was helpful.)
- https://stackoverflow.com/questions/74827422/curl-request-to-aws-lambda-function-receives-no-json
- https://pypi.org/project/python-lambda-local/ (I had difficulty testing the function at points because of differences using a function URL but this is a neat library to locally test Python-based Lambdas.)
- https://gist.github.com/thiagomgo/7f738b8d89a537ba1aa4d97d90b17c28 (gist for cURL from a Lambda in Python.)
- https://repost.aws/knowledge-center/image-builder-verification-ssm-agent (Helped with some troubleshooting.)
