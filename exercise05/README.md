# Exercise 5: Integrating with the Scheduler

In this exercise we take all the work we've done previously and make it work with a scheduler to solve the problems of placement and network allocation without our manual intervention.

We'll be using [Nomad](https://nomadproject.com) from Hashicorp. Nomad serves a similar purpose as other schedulers such as Kubernetes or Mesos/Marathon. Nomad is somewhat less feature rich than Kubernetes, but has some distinct advantages as well:

- The deployment is a single binary; a development environment can be just the Nomad binary which can launch Docker containers on your laptop.
- The overhead of deployment is minimal; a production cluster has an overhead of just 3 server nodes, which can share a host with the Consul servers.
- It can manage Docker containers and non-Docker workloads.

As a result of all the above, Nomad has fewer moving parts and is easy to understand. If you're familiar with the basics of containers, you can stand up a basic production-ready cluster very quickly.

### Our application on Nomad

Nomad uses a job configuration file, and a job can have multiple groups and tasks within it. (A "group" is the equivalent of a Kubernetes pod, and an instance of a "task" is a single container.) Our `app.nomad` job is a job with a single group and single task; you can run the Nginx task under Nomad as well, but we're going to leave that as an exercise for you to try at home.

Our plan file can tell Nomad how we want to place the container. In this case we're making sure we place the containers on an instance that has a recent kernel, but we can have it constained by either attributes of the machine or metadata we attach to the machine.

```hcl
constraint = {
  attribute = "${attr.kernel.version}"
  operator = ">="
  value = "4.0.0"
}
```

It also includes this block that tells Nomad what container to pull from a registry and what network mode to use. Note we can use `host` networking here and Nomad handles all the port assignment for us -- if we don't need to isolate containers' networks this is potentially a big network performance win (and reduction in complexity!).

```hcl
# we're going to deploy a Docker container that's been
# previously built (this is the image in the app/ directory)
driver = "docker"
config {
  image = "0x74696d/devopsdays-workshop"
  network_mode = "host"
}
```

Our plan file also includes the following bit that registers the container with Consul and creates a health check.

```hcl
# The service block tells Nomad how to register this service
# with Consul for service discovery and monitoring.
service {
  name = "workshop"
  port = "HTTP"
  check {
    type     = "http"
    path     = "/"
    interval = "5s"
    timeout  = "2s"
  }
}
```

Check the plan:

```
$ nomad validate app.nomad
Job validation successful

$ nomad plan app.nomad
nomad plan app.nomad
+ Job: "workshop-<TODO>"
+ Task Group: "workshop" (1 create)
  + Task: "frontend" (forces create)

  Scheduler dry-run:
  - All tasks successfully allocated.

  Job Modify Index: 0
  To submit the job with version verification run:

  nomad run -check-index 0 app.nomad

  When running the job with the check-index flag, the job will only be run if the
  server side version matches the job modify index returned. If the index has
  changed, another user has modified the job and the plan's results are
  potentially invalid.
```

Run the plan:

```
$ nomad run app.nomad
==> Monitoring evaluation "8cc7b182"
    Evaluation triggered by job "workshop-tgross"
    Allocation "3dee05d7" created: node "6bd1b023", group "workshop"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "8cc7b182" finished with status "complete"


$ nomad status workshop-tgross
ID            = workshop-tgross
Name          = workshop-tgross
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
workshop    0       1         0        0       0         0

Allocations
ID        Eval ID   Node ID   Task Group  Desired  Status   Created At
18d23fb9  8beb26b0  6bd1b023  workshop    run      running  07/23/17 18:38:56 UTC
```
