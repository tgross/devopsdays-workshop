# student/Dockerfile describes the environment that workshop students
# will have when they ssh into a workshop host via the sshd_config:
#   forceCommand docker run --rm -it
#                       --net=host \
#                       -v /var/run/docker.sock:/var/run/docker.sock \
#                       student

FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y \
            ca-certificates \
            curl \
            git \
            emacs-nox \
            vim \
            nano \
            moreutils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.05.0-ce.tgz \
    && tar --strip-components=1 -xvzf docker-17.05.0-ce.tgz -C /usr/local/bin \

RUN git clone https://github.com/tgross/devopsdays-workshop /root/workshop

WORKDIR /root/workshop
CMD [ "/bin/bash" ]
