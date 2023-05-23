# Reverse proxy for smartplaylist

Https reverse proxy for other applications.

```sh
docker run \
    -d --name reverseproxy \
    --network my-bridge-network \
    -p 80:80 -p 443:443 \
    -v /etc/letsencrypt:/etc/nginx/ssl:ro \
    -v $(pwd)/nginx/conf/:/etc/nginx/conf.d/:ro \
    nginx:1.23-alpine
```

## SSL Certificates

This requires adding a DNS TXT recrod.
This will setup automatic renewal of the certificates. Cloudflare API Token is needed for that purpose: <https://dash.cloudflare.com/profile/api-tokens>

1. `snap set certbot trust-plugin-with-root=ok`
1. `sudo snap install certbot-dns-cloudflare`
1. `certbot certonly --dns-cloudflare --dns-cloudflare-credentials /home/www/.secrets/certbot/cloudflare.ini -d smartplaylist.me`

I think after 2023-08-30 certificate will be renewed automatically, but `reverseproxy` restart will be required `docker restart reverseproxy`
