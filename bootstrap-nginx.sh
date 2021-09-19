#!/bin/bash
set -x

sudo yum install httpd-tools -y
echo $1
# Generate a dummy password
set +x
echo $(aws secretsmanager get-secret-value --secret-id $1 --query SecretString --output text | jq -r '."password"') | sudo htpasswd -ci /etc/nginx/.htpasswd "$(aws secretsmanager get-secret-value --secret-id $1 --query SecretString --output text | jq -r '."username"')"
set -x
## Modifying Nginx Server Configuration
cat > /tmp/nginx.conf <<EOL
    server {
        listen 80;
        auth_basic "";
        auth_basic_user_file /etc/nginx/.htpasswd;        

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
    server {
        listen 443 ssl;

        auth_basic "";
        auth_basic_user_file /etc/nginx/.htpasswd;

     
        ssl_certificate /etc/ssl/certs/nginx.crt;
        ssl_certificate_key /etc/ssl/certs/nginx.key;


        
        ssl_session_cache  builtin:1000  shared:SSL:10m;
        ssl_protocols  TLSv1.2;

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

EOL

sudo cp /tmp/nginx.conf /etc/nginx/conf.d/livyproxy.conf

#Add an include to the http directive
sudo sed -i 's/http {/http { \n    #CUSTOM INCLUDES \n    include \/etc\/nginx\/conf.d\/*.conf;\n    #END CUSTOM INCLUDES/' /etc/nginx/nginx.conf

sudo service nginx restart