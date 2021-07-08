#!/bin/bash
set -ex
echo "*****    Installing Nginx    *****"
apt update
apt install -y nginx
ufw allow '${ufw_allow_nginx}'
systemctl enable nginx
systemctl restart nginx

set +x

echo "*****   Installation Complteted!!   *****"

echo "Welcome to Google Compute VM Instance deployed using Terraform!!!" > /var/www/html

echo "*****   Startup script completes!!    *****"