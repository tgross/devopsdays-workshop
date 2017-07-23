FROM debian:jessie

RUN apt-get update \
    && apt-get install unzip \
    && rm -rf /var/lib/apt/lists/*

ENV NOMAD_VERSION 0.5.6

ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip /tmp/nomad.zip
RUN echo "3f5210f0bcddf04e2cc04b14a866df1614b71028863fe17bcdc8585488f8cb0c  /tmp/nomad.zip" > /tmp/nomad.sha256 \
    && sha256sum -c /tmp/nomad.sha256 \
    && cd /bin \
    && unzip /tmp/nomad.zip \
    && chmod +x /bin/nomad \
    && rm /tmp/nomad.zip

EXPOSE 4646
EXPOSE 4647
EXPOSE 4648

ADD ./nomad.hcl /config/nomad.hcl
VOLUME /data
ENTRYPOINT ["/bin/nomad", "agent", "-config=/config/nomad.hcl"]
