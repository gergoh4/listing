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
   db:
    image: mysql:5.7
    container_name: api_db
    command: --default-authentication-plugin=mysql_native_password --innodb-use-native-aio=0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Syscops1234sYSCOPS
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wp_user
      MYSQL_PASSWORD: sYSCOPS1234Syscops
    volumes:
      - ./data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    container_name: api_wordpress
    depends_on:
      - db
    restart: always
    volumes:
      - ./wp_data:/var/www/html
    links:
      - \"db:db\"
    environment:
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: sYSCOPS1234Syscops
      WORDPRESS_DB_HOST: db:3306

  webserver:
    build: .
    container_name: api_webserver
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
#ADD ssl /etc/nginx/ssl/
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

location / {
proxy_set_header Host \$host;
proxy_pass http://wordpress;
}

location ~ \.php$ {
 root html;
 fastcgi_pass 127.0.0.1:9000;
 fastcgi_index index.php;
 fastcgi_param SCRIPT_FILENAME /scripts\$fastcgi_script_name;
 include fastcgi_params;
}

location ~ /\.ht {
deny all;
}
}
}" > default.conf

docker-compose up -d
