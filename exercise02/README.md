# Exercise 2: Service Registration

This exercise demonstrates an in-process approach to service registration and health checking. We'll show that a consuming application (Nginx) needs to know how to find all the API instances, and how we can have the API instances leverage Consul to publish this information.

## Service catalog

Our shared Nginx instance (instructor will give a URL for this) is supposed to display all the avatars of the students. But currently it shows no avatars because it doesn't know how to find the API servers. For this we need a service catalog.

The goal of any service catalog is to be able to answer the question "where can I reach this service?" With this narrow definition, we could even consider a DNS server like `bind` a service catalog. But lots of software fails to respect DNS TTL, and DNS doesn't include port information (unless we use SRV records but these have poor language support). Instead we can use tools like Zookeeper, etcd, or Consul.

Each of the Docker hosts in our lab has a Consul agent running, and this Consul agent gossips configuration values with a 3-node cluster of Consul servers. You should be able to reach Consul from the localhost:

```bash
$ curl https://localhost:8500/v1/status/peers
[
  "192.168.1.12:8300",
  "192.168.1.11:8300",
  "192.168.1.10:8300"
]
```

## Updating the API to register with Consul

We can modify our API server to automatically register itself with Consul on startup. First, let's make sure our server is listening on the LAN address by editing the config file:

```json5
{
  name: "<your GitHub $ACCOUNT>",
  token: "<GitHub OAuth token>",
  host: "<fill in your $PRIVATE_IP>",
  port: <fill in your $PORT>
}
```

If we take a look at `server.py` we now have a new section for service registration, which we do at startup. The `register_service` function does the same thing as this `curl` request:

```bash
curl -XPUT \
     http://localhost:8500/v1/agent/service/register \
     --data @- <<EOF
     {
       "Name": "workshop",
       "ID": "workshop-tgross",
       "Address": "${PRIVATE_IP}",
       "Port": ${PORT}
     }
EOF
```

Let's build and run our API server with the new code:


```bash
# remove our previous container
$ cleanup

# rebuild with the new config file
$ docker build -t="workshop-$ACCOUNT" .

# run the container again
$ docker run -d -p ${PORT}:${PORT} --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
14521a456adf
```

Once our API servers have all started up and registered, we can see that they show up in the Consul server (the instructor will provide a URL to show this) and the now our Nginx page is showing all the avatars of everyone in the workshop!

We'll get into *how* the Nginx server uses this data in Exercise 3.


## Health checking

If we stop our API server, the Nginx server doesn't have any way of telling what went wrong.

```bash
$ docker stop "${ACCOUNT}"
```

Now the Nginx server will be getting 404s for all the iframes that should contain the avatar images. If we check the Consul server again we'll see that all the API servers are still reporting that they're ok.

To handle this case gracefully, we need to health check the service. This means periodically running a test of some kind to make sure that the service is still running at the address that we registered. Consul can be configured to check via sending an HTTP request, by making a TCP connection, by running a script, or by running a command in a Docker container via `docker exec`.

We can update our server to register an HTTP check.

```python
# ----------------------------------------
# configure and run the server

app = bottle.default_app()
with open('./config.json5', 'r') as f:
    cfg_file = f.read()
    app.config.load_dict(json5.loads(cfg_file))

register_service()
#register_check()                     <--- uncomment this line

run(host=app.config['host'], port=app.config['port'])
```

And then run our container again:


```bash
# remove our previous container
$ cleanup

# rebuild with the new config file
$ docker build -t="workshop-$ACCOUNT" .

# run the container again
$ docker run -d -p ${PORT}:${PORT} --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
abc34a456aee
```

We should start seeing a request every 10 seconds from Consul, and if we check the Consul server we'll see all the instances as green (healthy). Nginx is showing all the avatars again.

```bash
$ docker logs $ACCOUNT
...
```

If we stop our API servers again, the Consul will show the instances as "unhealthy" (orange), and the Nginx server will realize that something has gone wrong with that instance will not have it in its configuration anymore.

```bash
$ docker stop "${ACCOUNT}"
```
