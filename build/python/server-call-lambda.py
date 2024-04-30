def lambda_handler(event, context):
    import subprocess
    import base64
    import re
    import requests

    headers = {"user-agent": "lambdatest"}
    # Extract the server IP from the JSON payload
    ip = str(base64.b64decode(event["body"]))

    # Parse the IP address
    ip_parsed = "".join(re.findall(r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b", ip))

    # Call the server
    result = requests.get("http://" + ip_parsed, headers=headers)

    return result.text
