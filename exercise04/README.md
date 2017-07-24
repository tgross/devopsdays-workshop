# Exercise 4: Intro to ContainerPilot

In exercise 2 we used in-process code to perform service registration, and in exercise 3 we saw how we needed an init inside the container in order to safely handle child processes without resulting in zombies.

In this exercise, we'll update our applications to use ContainerPilot -- an init system for distributed applications, designed for use in containers. ContainerPilot is an open source project from Joyent (and originally designed/written by the instructor of this workshop).

ContainerPilot runs as PID1 inside the container. It reads a configuration file in JSON5 format, and uses this to run "jobs". If the user provides a port and interface specification for the job, ContainerPilot will also health check the job and publish it to the Consul service discovery catalog. The configuration in `./app/containerpilot.json5` below is for the workshop application.

```json5
{
  consul: "localhost:8500",
  jobs: [
    {
      name: "workshop",
      exec: "python /server.py",
      restarts: "unlimited",
      port: {{ .PORT }},              // will be read from environment
      interfaces: [ "net1", "lo0" ],  // ordered list, advertises 1st valid one
      health: {
        exec: "/health-check.sh",
        interval: 5,
        ttl: 11,
      }
    }
  ]
}
```

Note that our `server.py` code no longer needs the service registration code. This demonstrates how we can use ContainerPilot even for applications don't directly support service discovery (like most databases). But it does need to accept some values from the environment:

```python
app.config.load_dict({
    "name": os.environ['ACCOUNT'],
    "token": os.environ['OAUTH_TOKEN'],
    "host": os.environ.get('CONTAINERPILOT_WORKSHOP_IP', 'localhost'),
    "port": os.environ.get('PORT', 8080)
    })
```

The Nginx configuration in `./nginx/containerpilot.json5` is more complex. Here we have 3 jobs and two of them have a `when` field, which says not to start them until another job has completed. The `when` field can respond to success/failure, healthy/unhealthy, a change in the number of instances, etc. We're not showing it in this workshop, but ContainerPilot has a `watch` configuration option that allows it to monitor a service in Consul and respond to changes there.

Let's run the workshop app and Nginx again, this time using the ContainerPilot build.

```
# build and run the workshop server
$ cd app
$ docker build -t="workshop-$ACCOUNT" .
...
$ docker run -d \
    --net=host \
    --name "$ACCOUNT" \
    -p ${PORT}:${PORT} \
    -e PORT=${PORT} \
    -e ACCOUNT=${ACCOUNT} \
    -e OAUTH_TOKEN=${OAUTH_TOKEN} \
     "workshop-$ACCOUNT"
4528005eedde

# build and run the Nginx server
$ cd ../nginx
$ docker build -t nginx-$ACCOUNT .
...
$ docker run -d \
         --init \
         -e PUBLIC_IP=${PUBLIC_IP} \
         -e PORT=${PORT} \
         -p ${PORT}:${PORT} \
         --net=host \
         --name "nginx-$ACCOUNT" \
         "nginx-$ACCOUNT"
920dde8005ee
```
