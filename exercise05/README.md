# Exercise 5: Integrating with the Scheduler

In this exercise we take all the work we've done previously and make it work with a scheduler to solve the problems of placement and network allocation without our manual intervention.

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
