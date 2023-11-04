# Reverse Proxy services

Setup and management of a reverse proxy using Nginx. It redirects traffic from a specified domain/IP and distributes it to other applications based on the rules defined in `nginx/conf/default.conf`. It also manages SSL certification for secure HTTP traffic.

## Service Deployment

To deploy the reverse proxy service, run the following command with the necessary environment variables:

```sh
NETWORK_NAME=some_network
LOCAL_CERT_PATH=/etc/letsencrypt/live/example.com
# This path is used inside the container as defined in `nginx/conf/default.conf`
NGINX_CERT_PATH=/etc/nginx/ssl/live/example.com

docker run -d --name reverseproxy --network $NETWORK_NAME \
    -p 80:80 -p 443:443 \
    -v $LOCAL_CERT_PATH/fullchain.pem:$NGINX_CERT_PATH/fullchain.pem:ro \
    -v $LOCAL_CERT_PATH/privkey.pem:$NGINX_CERT_PATH/privkey.pem:ro \
    -v $REVERSE_PROXY_DIR/nginx/conf/:/etc/nginx/conf.d/:ro \
    nginx:1.23-alpine
```

## Debugging Procedures

- To verify if the container is active: `docker ps | grep reverseproxy`
- To tail the latest logs: `docker logs -n 100 -f reverseproxy`

## SSL Certificate Management

The SSL certificates have a 90-day validity and are set to auto-renew every 60 days. Certificates are provided to the reverse proxy container through Docker volumes and can be generated with `certbot` using the `certbot-dns-cloudflare` plugin.

### Certbot Configuration

A dry run for certificate renewal can be executed with the following command:

```sh
certbot certonly --dns-cloudflare \
--dns-cloudflare-credentials /home/www/.secrets/certbot/cloudflare.ini \
-d example.com --non-interactive --dry-run
```

- Obtain a Cloudflare API Token [here](https://dash.cloudflare.com/profile/api-tokens) and store it in `/home/www/.secrets/certbot/cloudflare.ini`.
- Certbot stores certificates in `/etc/letsencrypt/archive/example.com/`, with symlinks in `/etc/letsencrypt/live/example.com/`.
- Renewal configurations are found at `/etc/letsencrypt/renewal/example.com.conf`.
- Verify the Certbot timer with `systemctl list-timers | grep certbot`. This timer checks for certificate renewals.
- Certbot timer configurations are in `/etc/systemd/system/snap.certbot.renew.timer`.
- To apply timer changes: `systemctl daemon-reload` followed by `systemctl restart snap.certbot.renew.timer`.
- Review Certbot service activity: `journalctl -u snap.certbot.renew.service`
- Check Certbot logs: `tail -n 100 /var/log/letsencrypt/letsencrypt.log`

### Nginx Certificate Reload

To apply new certificates, Nginx must reload. This is handled automatically by a `certbot` deploy hook:

- Link the deploy hook script: `ln -s /home/www/.secrets/certbot/reload-nginx-container.sh /etc/letsencrypt/renewal-hooks/deploy/reload-nginx-container.sh`

### Certbot Installation Steps

To install and set up Certbot with the Cloudflare plugin, use the following commands:

1. Install Certbot: `snap install --classic certbot`
2. Create a symlink for easy access: `ln -s /snap/bin/certbot /usr/bin/certbot`
3. Trust the Cloudflare plugin with root privileges: `snap set certbot trust-plugin-with-root=ok`
4. Install the Cloudflare DNS plugin: `snap install certbot-dns-cloudflare`
5. Perform a dry run to ensure configurations are correct: `certbot certonly --nginx -d example.com -d www.example.com --dry-run`

Please replace `example.com` with your actual domain throughout this documentation.
