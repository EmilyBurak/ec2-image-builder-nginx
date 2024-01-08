#!/bin/bash

# Update system packages
yum update -y

# Install nginx
yum install -y nginx

# Configure nginx to listen on port 80
sed -i 's/listen       80;/listen       80 default_server;/g' /etc/nginx/nginx.conf

# Enable logging
sed -i 's/# access_log/access_log/g' /etc/nginx/nginx.conf

# Start nginx service
systemctl start nginx

# Enable nginx service to start on boot
systemctl enable nginx
