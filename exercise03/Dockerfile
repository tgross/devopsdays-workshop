FROM nginx:1.13-alpine

RUN curl -fsSLO https://releases.hashicorp.com/consul-template/0.19.0/consul-template_0.19.0_linux_amd64.tgz \
    && tar -xvzf consul-template_0.19.0_linux_amd64.tgz -C /usr/local/bin

COPY index.html /index.html
COPY site.conf /site.conf
COPY run.sh /run.sh

CMD [ "/run.sh" ]
