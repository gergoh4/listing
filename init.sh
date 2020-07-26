#!/bin/bash
#Wordpress
apt-get update
apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
apt-get install docker-ce -y
curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir Wordpress
cd Wordpress
touch docker-compose.yml
echo "version: '3'
services:
wordpress:
image: wordpress:latest
depends_on:
- db
restart: always
volumes:
- ./wp_data:/var/www/html
links:
- \"db:db\"
environment:
WORDPRESS_DB_USER: wp_user
WORDPRESS_DB_PASSWORD: 7rHBE1QJAtUWeGW3LjNhhWDkgaLDcaAm
WORDPRESS_DB_HOST: db:3306

db:
image: mysql:5.7
command: --default-authentication-plugin=mysql_native_password --innodb-use-native-aio=0
restart: always
environment:
MYSQL_ROOT_PASSWORD: NZe9ZmZpv00LDYZoRWCNcC4KvaIJKGFM
MYSQL_DATABASE: wordpress
MYSQL_USER: wp_user
MYSQL_PASSWORD: 7rHBE1QJAtUWeGW3LjNhhWDkgaLDcaAm
volumes:
- ./data:/var/lib/mysql

web:
build: .
volumes:
- ./default.conf:/etc/nginx/conf.d/default.conf
ports:
- \"80:80\"
- \"443:443\"
links:
- \"wordpress:wordpress\"
depends_on:
- wordpress
- db
"> docker-compose.yml
touch Dockerfile
echo "FROM nginx
WORKDIR /usr/share/nginx/html/
COPY default.conf /etc/nginx/conf.d/
# ADD ssl /etc/nginx/ssl/
EXPOSE 443
EXPOSE 80" > Dockerfile
touch default.conf
echo "server {
listen 80;
listen [::]:80;
server_name localhost;

#location / {
#root /usr/share/nginx/html;
#index index.html index.htm;
#}

error_page 500 502 503 504 /50x.html;
location = /50x.html {
root /usr/share/nginx/html;
}

# proxy the PHP scripts to Apache listening on 127.0.0.1:80

location / {
proxy_set_header Host \$host;
proxy_pass http://wordpress;
}

# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
#
#location ~ \.php$ {
# root html;
# fastcgi_pass 127.0.0.1:9000;
# fastcgi_index index.php;
# fastcgi_param SCRIPT_FILENAME /scripts\$fastcgi_script_name;
# include fastcgi_params;
#}

# deny access to .htaccess files, if Apache's document root
# concurs with nginx's one
#
#location ~ /\.ht {
# deny all;
#}
}

#server {
# listen 443 ssl;
# server_name _;

# #ssl_certificate /etc/nginx/ssl/server.crt;
# #ssl_certificate_key /etc/nginx/ssl/server-rsa.key;
# ssl_certificate /etc/nginx/ssl/certificate.crt;
# ssl_certificate_key /etc/nginx/ssl/private.key;
# ssl_trusted_certificate /etc/nginx/ssl/ca_bundle.crt;
#
# ssl_protocols TLSv1.3 TLSv1.2 TLSv1.1 TLSv1;
#
# access_log /var/log/nginx/access.log main;
# error_log /var/log/nginx/error.log info;
#
# location / {
# #proxy_http_version 1.1;
# #proxy_set_header Upgrade \$http_upgrade;
# #proxy_set_header Connection 'upgrade';
# proxy_set_header Host \$host;
# #proxy_set_header X-Forwarded-For \$remote_addr;
# proxy_set_header X-Forwarded-Proto \$scheme;
# #proxy_cache_bypass \$http_upgrade;
# #proxy_set_header X-Real-IP \$remote_addr;
# #proxy_read_timeout 300;
# #proxy_connect_timeout 300;
# #proxy_set_header Host \$host;
# proxy_pass http://wordpress;
# }
#}" > default.conf

docker-compose up -d
