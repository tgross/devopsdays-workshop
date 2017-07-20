#!/bin/bash
set -e

# rewrite the template config for Nginx
sed -i "s/PUBLIC_IP/${PUBLIC_IP}/" /site.conf
sed -i "s/PORT/${PORT}/" /site.conf

# render template once before starting up nginx
consul-template \
    -once \
    -template "/site.conf:/etc/nginx/conf.d/site.conf" \
    -template "/index.html:/usr/share/nginx/index.html"

# run Nginx in the background
nginx &

# watch Consul in the background and render its config file watch
consul-template \
    -template "/site.conf:/etc/nginx/conf.d/site.conf:pkill -SIGHUP nginx" \
    -template "/index.html:/usr/share/nginx/index.html"
