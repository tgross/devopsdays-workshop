#!/bin/bash

# rewrite the template config for Nginx
sed -i "s/PUBLIC_IP/${PUBLIC_IP}/" /site.conf

# run Nginx in the background
nginx &

# watch Consul in the background and render its config file watch
consul-template \
    -template "site.conf:/etc/nginx/conf.d/site.conf:pkill -SIGHUP nginx" \
    -template "index.html:/usr/share/nginx/index.html"
