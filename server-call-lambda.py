def lambda_handler(event, context):
    import subprocess
    import base64
    import re

    # Extract the server IP from the JSON payload
    ip = str(base64.b64decode(event["body"]))

    ip_parsed = "".join(re.findall(r"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b", ip))

    result = subprocess.call(f"curl -I http://{ip_parsed}", shell=True)
    return result
