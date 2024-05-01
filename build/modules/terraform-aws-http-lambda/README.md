# AWS HTTP Lambda

This module provisions a Lambda function meant to use `requests` in Python to query a given endpoint whiel passing a specific user-agent string for identifying the call in logs. This function is set up behind a public function URL with CORS configuration. A basic IAM role is created with a policy to allow Lambda to assume and execute using the role. Finally, deployment is handled via. checking the `/build/python` directory for an updated `server-call-lambda.py`, zipping it and uploading it to Lambda.
