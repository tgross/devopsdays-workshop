# Exercise 1: Defining the Problem

This exercise demonstrates some of the operational problems that applications in containers face.

Container schedulers (such as Kubernetes or Nomad) have a large number of responsibilities. Some of these responsibilities are inherent to the problem, whereas others are incidental. To understand which is which, we need to answer the question of "what do containers need in order run?"

A container needs:
- an image
- placement: CPU and memory on the host (ideally with good utilization)
- disk storage (optionally)
- networking: an IP address, possibly a public IP address, and port allocations or some kind of overlay networking
- service discovery: an ability to find its dependent services

For purpose of this workshop, we're not going to address the question of an image for the container, and we'll mostly put off disk storage (this is very platform-specific). We'll come back to the question of placement towards the end of the workshop. So let's examine the problems of networking.

## Our application

Our demonstration application is a minimal HTTP API written in Python (using the Bottle framework). It takes a configuration file and serves one path: `/user`. When the application gets a request on this path, it makes an outbound request to the GitHub API and fetches the URL associated with the avatar for the configured user, and this URL is returned in the JSON body.

We'll run the application in a Docker container.

First, let's check our config.json5. It should have been modified on login to include your GitHub account as the `name` field.

```json5
{
  name: "<your GitHub $ACCOUNT>",
  host: "localhost",
  port: 8080
}
```

## Run on local host w/ NAT

```bash
# build and run the container using the default networking
$ docker build -t="workshop-$ACCOUNT"
$ docker run -d -p 8080 --name "$ACCOUNT" "workshop-$ACCOUNT"
920dde8005ee

$ curl localhost:8080
curl: (7) Failed to connect to localhost port 8080: Connection refused

# what gives? let's check the container
$ docker ps -f name=$ACCOUNT
CONTAINER ID        IMAGE               COMMAND              CREATED            STATUS             PORTS                     NAMES
920dde8005ee        workshop-tgross     "python server.py"   1 minute ago       Up 1 minute        0.0.0.0:32769->8080/tcp   tgross

# ah we have NAT, so we need to change the address
$ curl localhost:32769
curl: (52) Empty reply from server

# our application isn't listening on the same "localhost"!
# it has a separate network!
```

## Run on localhost w/ host networking, fixed port




```bash
# remove our previous container
$ cleanup

# run the same container with host networking
$ docker run -d -p 8080 --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
ab4234a46eff

# let's make sure it's up
$ docker ps -af name=$ACCOUNT
CONTAINER ID        IMAGE               COMMAND              CREATED             STATUS                     PORTS     NAMES
ab4234a46eff        workshop-tgross     "python server.py"   4 seconds ago       Exited (1) 3 seconds ago             tgross

# why did it crash?
# note: yours might not have crashed if you were fastest on your VM

# with --net=host we share the network namespace with everyone
# else on the same VM, so we can have port conflicts

$ docker logs $ACCOUNT
Bottle v0.12.13 server starting up (using WSGIRefServer())...
Listening on http://localhost:8080/
Hit Ctrl-C to quit.

Traceback (most recent call last):
  File "server.py", line 28, in <module>
    run(host=app.config['host'], port=app.config['port'])
  File "/usr/local/lib/python3.6/site-packages/bottle.py", line 3127, in run
    server.run(app)
  File "/usr/local/lib/python3.6/site-packages/bottle.py", line 2781, in run
    srv = make_server(self.host, self.port, app, server_cls, handler_cls)
  File "/usr/local/lib/python3.6/wsgiref/simple_server.py", line 153, in make_server
    server = server_class((host, port), handler_class)
  File "/usr/local/lib/python3.6/socketserver.py", line 453, in __init__
    self.server_bind()
  File "/usr/local/lib/python3.6/wsgiref/simple_server.py", line 50, in server_bind
    HTTPServer.server_bind(self)
  File "/usr/local/lib/python3.6/http/server.py", line 136, in server_bind
    socketserver.TCPServer.server_bind(self)
  File "/usr/local/lib/python3.6/socketserver.py", line 467, in server_bind
    self.socket.bind(self.server_address)
OSError: [Errno 98] Address already in use

```

## Run on localhost w/ host networking, random port

Edit our config.json5 as follows:

```json5
{
  name: "<fill in your $ACCOUNT>",
  host: "localhost",
  port: <fill in your $PORT>
}
```

```bash
# remove our previous container
$ cleanup

# rebuild with the new config file
$ docker build -t="workshop-$ACCOUNT"

# run the container again
$ docker run -d -p ${PORT}:${PORT} --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
eb4234756abc

$ docker ps -f name=$ACCOUNT
CONTAINER ID        IMAGE               COMMAND              CREATED            STATUS             PORTS                     NAMES
eb4234756abc        workshop-tgross     "python server.py"   1 minute ago       Up 1 minute        0.0.0.0:8080->8080/tcp   tgross

$ curl "localhost:${PORT}"
{
  "user": "tgross",
  "avatar_url": "https://avatars0.githubusercontent.com/u/1409219?v=3"
}
```

Note that this requires cooperation of the application to accept an assigned dynamic port, but it avoids all overhead associated with an overlay networking solution. Suitable if you don't need multi-tenant safety.


## Run on public IP w/ host networking, random port

We still haven't seen what this looks like, and we bind to localhost. So let's update our configuration to publish the API on the Internet.

Edit our config.json5 as follows:

```json5
{
  name: "<fill in your $ACCOUNT>",
  host: "<fill in your $PUBLIC_IP",
  port: <fill in your $PORT>
}
```

```bash
# remove our previous container
$ cleanup

# rebuild with the new config file
$ docker build -t="workshop-$ACCOUNT"

# run the container again
$ docker run -d -p ${PORT}:${PORT} --net=host --name "$ACCOUNT" "workshop-$ACCOUNT"
14521a456adf
```

Now you should be able to reach your container from your browser, and fetch your own avatar. The URL `http://${PUBLIC_IP}:${PORT}/user` will reach the JSON API, whereas the URL `http://${PUBLIC_IP}:${PORT}/` will reach a simple web page that shows the avatar and your name.


## Overlay networking

A third option is to use an overlay networking solution -- which is a class of solutions that give each container its own network stack and IP address on the LAN. Some implementations:

- Docker overlay networking: go see Jerome's workshop at 2:30pm!
- Calico: based on BGP (strictly speaking not "overlay")
- Flannel: VXLAN or platform-specific backends (ex. AWS VPC)
- Triton: uses VXLAN for routing (demo Consul servers)

Most of the major schedulers expect containers to have their own IP address. Kubernetes expects each pod of containers to have its own IP address which is shared among containers in the pod. Containers in the pod communicate with each other over localhost. Kubernetes provides CNI plugins for solutios like Flannel and Calico.
