# Exercise 0

In this exercise we ssh into the development environment and check that we're properly set up.


### Shell

Each student can ssh into a machine w/ the exact IP and password given out by instructor. This puts each student into a container which has all the tools we need and access to the `docker.sock` on the machine. Each host has 4 students to demonstrate problems with application tenancy. Note that if you exit the container it will be destroyed.


```
$ ssh student@AAA.BBB.CCC.DDD
```


### Configuration

Once shelled in, we need to make sure that each student has a properly set up environment and that certain environment variables are correctly set up:

```
$ cd ./exercise00
$ eval "$(./check.sh)"
```

The output should be something resembling the following:

```
This workshop will use your GitHub account name as a unique identifier.
We won't grant any permissions on the account, but the demo app will
your avatar from GitHub so please use a real account name.

Enter your GitHub account name: <your account name>

* checking that you have access to Docker engine on host...
ok!

* fetching environment variables...
ok!

* exporting workshop environment to your shell...
ok!

* exported the following workshop environment:

ACCOUNT=<your account name>
PORT=<random port>
PRIVATE_IP=<IP on our cluster's LAN>
PUBLIC_IP=<IP on the public internet>
```
