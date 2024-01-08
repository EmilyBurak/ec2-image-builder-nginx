#!/bin/bash
ip="$(curl https://checkip.amazonaws.com)"
echo "The instance's public IP address is: $ip"
# use JQ to create a JSON payload to send to Lambda function containing the IP address of the instance
pl="$(jq -n --arg ip "$ip" '{server_ip: $ip}')"
echo "Payload to send to Lambda: $pl"
# REPLACE WITH YOUR LAMBDA FUNCTION URL!
curl -v -k https:<lambda function URL> -d "$pl"
# check the nginx access log to see if the request was received
sudo cat /var/log/nginx/access.log