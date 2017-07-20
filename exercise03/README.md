# Exercise 3: Dynamic Configuration

In the previous exercise we showed how applications can publish configuration data to a service catalog, so in this exericse we'll demonstrate how an application can consume this data. We'll build a dynamically-updated Nginx configuration using `consul-template`.

## Nginx configuration

First let's make sure we have data to work with. We start our app and then we can check with Consul to make sure it's been registered and is healthy.

```bash
# remove any old containers or checks and then start our app again
$ cleanup
$ docker run -d -p ${PORT}:${PORT} --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
abc34a456aee

# query Consul
$ curl http://localhost:8500/v1/health/service/workshop | jq .
...
```

In the previous exercise we saw demonstrated that Nginx has two endpoints that are interesting. One makes a request to a single avatar API server, and the other collects information from all the API servers.

The `site.conf` file is a configuration template for Nginx. The template syntax tells a tool called `consul-template` what values to fetch from Consul and rewrite in the `site.conf` file whenever something changes.

```config
{{ if service "workshop" }}
upstream workshop {
    {{ range service "workshop" }}
    server {{ .Address }}:{{ .Port }};
    {{ end }}
}{{ end }}

....

location /user {
    {{ if service "workshop" }}
    proxy_pass http://workshop;
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    {{ else }}
    return 503;
    {{ end }}
}

```

If there is a service called "workshop" in Consul, then we will render an Nginx `upstream` block with a `server` line for each instance of our workshop API server. Likewise, the `location /user` block will be proxied to those upstreams instead of returning a 503.

Let's first try this ourselves by doing it outside the container.

```bash
# backup the template file
$ cp site.conf site.conf.bak

$ consul-template -once -template "site.conf.bak:site.conf.new"
$ less site.conf.new
...

upstream workshop {
    # should see lots of these!
    server 192.168.1.101:5633;
    server 192.168.1.102:7899;
    server 192.168.1.103:8012;
}
...

location /user {
    proxy_pass http://workshop;
    proxy_redirect off;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}

```

## Web page rewriting

The `index.html` file is a template for the webpage that Nginx shows when we hit the root URL. Here we use the template language to render a new tile for each instance of the `workshop` service. (Note that we're cheating a bit here because we're counting on round-robin to get us an equal distribution to all the servers rather than rendering the specific instances.)

```html
<html>
<head>
<style>
#container {
  display: grid;
  grid: repeat(5, 160px) / auto-flow 160px;
}

#container > iframe {
  background-color: #8ca0ff;
  width: 150px;
  height: 150px;
}
</style>
</head>
<body>
  <div id="container">
    {{ range service "workshop" }}
    <iframe src="/user" />  <!-- we round-robin all the users -->
    {{ end }}
  </div>
</body>
</html>
```

## Multi-process containers

If we want to run both Nginx and consul-template in our container, we now have multiple processes in the container. Whenever this happens, we need to make sure that we don't get "zombie" processes. Imagine the following:

```bash
#!/bin/bash

# run Nginx in the background
nginx &

# watch Consul in the background and render its config file watch
consul-template \
    -template "site.conf:/etc/nginx/conf.d/site.conf:pkill -SIGHUP nginx" \
    -template "index.html:/usr/share/nginx/index.html"
```

Outside of a container we always have an init system (like `launchd` on MacOS, `systemd` on Linux, or `upstart` or `sysVinit` on older Linux systems). This means that when `consul-template` runs the `pkill` command, the entry for that process in the process table gets cleaned up. If the entry doesn't get cleaned up this is called a "zombie," and zombie processes will eventually eat up the process table.

If we want to run more than one process in a container, we should always do so with an init system. In this exercise we'll use the ["tiny init"](https://github.com/krallin/tini) baked into Docker by passing the `--init` flag. We'll see an alternative approach in the next exercise.

## Run it!

```bash
# build and run the Nginx server
$ docker build -t nginx-$ACCOUNT .
$ docker run -d \
         --init \
         -e PUBLIC_IP=${PUBLIC_IP} \
         -e PORT=${PORT} \
         -p ${PORT}:${PORT} \
         --net=host \
         --name "nginx-$ACCOUNT" \
         "nginx-$ACCOUNT"
920dde8005ee

# we should still have our app server running
# let's check on our containers

$ docker ps -f name=$ACCOUNT
CONTAINER ID        IMAGE               COMMAND              CREATED            STATUS             PORTS                     NAMES
abc34a456aee        workshop-tgross     "python server.py"   2 minutes ago      Up 2 minutes       8123->8123/tcp           tgross
920dde8005ee        nginx-tgross        "/run.sh"            1 minute ago       Up 1 minute        0.0.0.0:8123->80/tcp     nginx-tgross
```

Note that because our application server is binding to the `${PRIVATE_IP}` address only and not localhost or the public IP address, Nginx can use the same port so long as it's binding to the `${PUBLIC_IP}` address only. We had to update the Nginx configuration before starting it in order for that to work. The `/run.sh` script does all this for us, but what if our init system could give us help? Let's see how in Exercise 4!
