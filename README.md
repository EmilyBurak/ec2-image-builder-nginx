# ec2-image-builder-nginx Resources

This repository contains resources for [EC2 Image Builder](https://aws.amazon.com/image-builder/), including scripts and code snippets that can be used in a pipeline to install and test nginx by calling a Lambda that curls the Image Builder test instance.

## install-nginx.sh

The `install-nginx.sh` script is a user data script that installs nginx as part of the EC2 Image Builder pipeline on an AWS 2023 Linux x86 instance(I haven't tested it on other setups). It can be used to configure and set up nginx on EC2 instances.

## server-call-lambda.py

The `server-call-lambda.py` script is a Lambda function written in Python. It uses the `subprocess` library to make a curl request to a given server.

## invoke-lambda.sh

The `invoke-lambda.sh` script is a bash script that invokes the `server-call-lambda.py` Lambda function as part of the EC2 Image Builder pipeline.

Please refer to the individual script files for more details on their usage and configuration.

# Setup

- You'll need to set up a Lambda off of `server-call-lambda.py` with a function URL that you'll substitute into the code of `invoke-lambda.sh` when you use it with CORS setup to receive POST requests
- You'll need to create a Test Component for the pipeline to invoke the lambda based off of `invoke-lambda.sh`
- Needs a security group allowing port 80 for nginx set up
- Needs a VPC with a subnet with `auto-assign public ip` on for the infrastructure configuration
- Need to set up an IAM role with the appropriate policies
  - EC2InstanceProfileForImageBuilder
  - AmazonSSMManagedInstanceCore
    - Otherwise you'd be stuck using the default role which in the UI at least won't let you select a custom VPC and security group.

# Future Work

- Would like to put the Image Builder resources into Terraform instead of needing an initial manual configuration.
- The code for the lambda itself is clunky, I switched from `requests` partway through, and needing a regex to a public function url is ugly.
  - I'd rather call it with the AWS CLI and set up authentication properly.
- Better error handling in the bash and better validation of the received nginx request from the lambda.

# Resources

- https://www.shellcheck.net/#
- https://spin.atomicobject.com/jq-creating-updating-json/
- https://stackoverflow.com/questions/74827422/curl-request-to-aws-lambda-function-receives-no-json
- https://pypi.org/project/python-lambda-local/
- https://gist.github.com/thiagomgo/7f738b8d89a537ba1aa4d97d90b17c28
