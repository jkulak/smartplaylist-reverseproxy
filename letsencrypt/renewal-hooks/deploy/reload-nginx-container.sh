#!/bin/bash

# This script is used to restart the running reverse proxy container
# so it uses the new certificates.

# Automating the Deploy Hook: Certbot stores deploy hook scripts
# that are to be run with every renewal in the directory
# /etc/letsencrypt/renewal-hooks/deploy/.
# By placing your script in this directory,
# it should execute automatically upon each renewal.

REVERSE_PROXY_DIR=/home/www/smartplaylist-reverseproxy
NETWORK_NAME=smartplaylist_network
NGINX_CERT_PATH=/etc/nginx/ssl/live/smartplaylist.me
LOCAL_CERT_PATH=/etc/letsencrypt/live/smartplaylist.me

# Stop the reverse proxy container
docker stop reverseproxy

# Remove the reverse proxy container
docker rm reverseproxy

# Start the reverse proxy container
docker run -d --name reverseproxy --network $NETWORK_NAME \
    -p 80:80 -p 443:443 \
    -v $LOCAL_CERT_PATH/fullchain.pem:$NGINX_CERT_PATH/fullchain.pem:ro \
    -v $LOCAL_CERT_PATH/privkey.pem:$NGINX_CERT_PATH/privkey.pem:ro \
    -v $REVERSE_PROXY_DIR/nginx/conf/:/etc/nginx/conf.d/:ro nginx:1.23-alpine
