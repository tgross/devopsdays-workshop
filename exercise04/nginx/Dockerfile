FROM nginx:1.13-alpine

RUN apk --no-cache add curl bash

RUN curl -fsSLO "https://releases.hashicorp.com/consul-template/0.19.0/consul-template_0.19.0_linux_amd64.tgz" \
    && tar -xvzf consul-template_0.19.0_linux_amd64.tgz -C /usr/local/bin

RUN curl -fsSLO "https://github.com/joyent/containerpilot/releases/download/3.3.0/containerpilot-3.3.0.tar.gz" \
    && tar -xvzf containerpilot-3.3.0.tar.gz -C /usr/local/bin

COPY . ./
CMD [ "containerpilot", "-config", "/containerpilot.json" ]
