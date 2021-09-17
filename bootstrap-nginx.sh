#!/bin/bash -xe


sudo amazon-linux-extras install nginx1.12 -y
sudo yum install openssl httpd-tools -y

# Create a self-signed cert
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/nginx.key -out /etc/ssl/certs/nginx.crt -subj "/CN=localhost"

# Generate a dummy password
echo livy | sudo htpasswd -ci /etc/nginx/.htpasswd livy

## Modifying Nginx Server Configuration
sudo cat > ~/nginx.conf <<EOL
user nginx;
worker_processes auto;
include /usr/share/nginx/modules/*.conf;
events { }
http {

    #server {
    #    listen 8080;
    #    return 301 https://$host$request_uri;
    #}
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        auth_basic "";
        auth_basic_user_file /etc/nginx/.htpasswd;

        # Certificate
        # ssl_certificate /etc/ssl/certs/nginx.crt;
        # Private Key
        # ssl_certificate_key /etc/ssl/certs/nginx.key;    

        # ssl on;
        # ssl_session_cache  builtin:1000  shared:SSL:10m;
        # ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        # ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
        # ssl_prefer_server_ciphers on;          
        location / {
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header Host \$http_host;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_http_version 1.1;
            proxy_pass http://localhost:8998;
            proxy_redirect off;
            proxy_read_timeout 240s;
        }
    }
}
EOL
sudo cp ~/nginx.conf /etc/nginx/nginx.conf
## Starting Nginx Services
sudo chkconfig nginx on
sudo service nginx start
sudo service nginx restart