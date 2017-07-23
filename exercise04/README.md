# Exercise 4: Intro to ContainerPilot

In exercise 2 we used in-process code to perform service registration, and in exercise 3 we saw how we needed an init inside the container in order to safely handle child processes without resulting in zombies. In this exercise, we'll update our applications to use ContainerPilot -- an init system for distributed applications, designed for use in containers.


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
