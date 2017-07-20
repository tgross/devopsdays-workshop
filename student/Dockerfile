# student/Dockerfile describes the environment that workshop students
# will have when they ssh into a workshop host.

FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y \
            ca-certificates \
            curl \
            git \
            emacs-nox \
            vim \
            nano \
            jq \
            moreutils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-17.05.0-ce.tgz \
    && tar --strip-components=1 -xvzf docker-17.05.0-ce.tgz -C /usr/local/bin

RUN curl -fsSLO https://releases.hashicorp.com/consul-template/0.19.0/consul-template_0.19.0_linux_amd64.tgz \
    && tar -xvzf consul-template_0.19.0_linux_amd64.tgz -C /usr/local/bin

# clone the workshop and make sure we've set up a bash profile
# with the appropriate environment setup
RUN git clone https://github.com/tgross/devopsdays-workshop /root/workshop
COPY .bash_aliases  /root/.bash_aliases

WORKDIR /root/workshop
CMD [ "/bin/bash" ]
