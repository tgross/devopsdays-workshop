# Exercise 4: Intro to ContainerPilot

In exercise 2 we used in-process code to perform service registration, and in exercise 3 we saw how we needed an init inside the container in order to safely handle child processes without resulting in zombies. In this exercise, we'll update our applications to use ContainerPilot -- an init system for distributed applications, designed for use in containers.
