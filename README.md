# Reverse proxy for smartplaylist

Https reverse proxy for other applications.

```sh
docker run \
    -d --name www \
    --network my-bridge-network \
    -p 80:80 -p 443:443 \
    -v $(pwd)/certbot/www:/etc/nginx/ssl/live/smartplaylist.me/:ro \
    -v $(pwd)/nginx/conf/:/etc/nginx/conf.d/:ro \
    nginx:1.23-alpine
```
