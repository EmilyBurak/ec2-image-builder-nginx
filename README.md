# ec2-image-builder-nginx Resources

This repository contains resources for [EC2 Image Builder](https://aws.amazon.com/image-builder/), including YAML components running bash scripts that can be used in a pipeline to install and test nginx by calling a Python Lambda that calls with `requests` the Image Builder test instance to confirm nginx is working. All the setup is done via. Terraform.

## install-nginx.yaml

The `install-nginx.yaml` component is a Build stage component in bash for EC2 Image Builder that installs nginx as part of the EC2 Image Builder pipeline on an AWS 2023 Linux x86 instance(I haven't tested it on other setups), listening on port 80 and logging to the `access_log`. It can be used to configure and set up nginx on EC2 instances.

## server-call-lambda.py

The `server-call-lambda.py` script is a Lambda function written in Python. It uses the `requests` library to make a request to a given server, in this case given during pipeline execution's Test stage. It passes the user agent string so that the request can be `grep`'d for in the logs to confirm its existence.

## invoke-http-lambda.yaml

The `invoke-http-lambda.yaml` component is a Test stage component in bash that invokes the `server-call-lambda.py` Lambda function as part of the EC2 Image Builder pipeline, passing the public IP of the test instance to be called back by the Lambda(to test accessing the server remotely) and then looks with `grep` in the `access_log` for the resultant entry from the Lambda identified by the user agent string.

Please refer to the individual script/configuration files for more details. Hopefully they're demonstrative and 'self-documenting' where I haven't left comments.

## .tf files

These are Terraform configuration files that set up the infrastructure needed to run the pipeline, including the pipeline and its components.

# Setup

You'll need:

- AWS CLI credentials set up
- Terraform set up

# To Use

- Run the usual Terraform workflow to create the resources
- Run the Image Builder pipeline to see if it works!
  - It won't work until you modify the `invoke-http-lambda.yaml` with the function URL. I'll add a `yamlencode` to fix this at some point.

# Future Work

- The code for the lambda itself is clunky, needing a regex to request the right address using a public function url is ugly. Gotta be a better way.
  - I'd rather call it with the AWS CLI and set up authentication properly.
- Better error handling in the bash and better validation of the received nginx request from the lambda, generally make the output more verbose and demonstrative of what is happening in the Test component.
- Modularize that TF.

# Resources

- https://www.shellcheck.net/ (really cool bug checker for shell scripts that got me past some syntax errors.)
- https://spin.atomicobject.com/jq-creating-updating-json/ (I hadn't used jq much, especially to create JSON, so this was helpful.)
- https://stackoverflow.com/questions/74827422/curl-request-to-aws-lambda-function-receives-no-json
- https://pypi.org/project/python-lambda-local/ (I had difficulty testing the function at points because of differences using a function URL but this is a neat library to locally test Python-based Lambdas.)
- https://gist.github.com/thiagomgo/7f738b8d89a537ba1aa4d97d90b17c28 (gist for cURL from a Lambda in Python.)
- https://repost.aws/knowledge-center/image-builder-verification-ssm-agent (Helped with some troubleshooting.)
