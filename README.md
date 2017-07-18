# Designing Self-Orchestrating Applications

## Abstract

Deploying applications in containers and connecting them together is a challenge because it forces developers to design for orchestration. The container ecosystem has largely converged on abstracting orchestration away from the developer and making the infrastructure more intelligent. If instead we push the responsibility for understand startup, service discovery, scaling, and recovery from failure into the application, we can build architectures that empower application development teams to understand how the software they write works in production.

But even if we accept this premise, we can’t simply rewrite all our applications, so we need a way to build application containers that can knit together legacy and greenfield applications alike. In this hands-on workshop, we will build a microservices application. Starting from simple open source components, we’ll add tooling that turns these applications into a modern self-assembling stack.


## Exercises

- [Exercise 0: Development Environment](./exercise00/README.md)
- [Exercise 1: Defining the Problem](./exercise01/README.md)
- [Exercise 2: Service Registration](./exercise02/README.md)
- [Exercise 3: Using Init in a Container](./exercise03/README.md)
- [Exercise 4: Intro to ContainerPilot](./exercise04/README.md)
- [Exercise 5: Dynamic Configuration](./exercise05/README.md)
- [Exercise 6: Integrating with the Scheduler](./exercise06/README.md)
