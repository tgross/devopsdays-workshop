#!/bin/sh
set -e

# we get the CONTAINERPILOT_NGINX_IP automatically
# from ContainerPilot.
# we use --fail so that this script returns a non-zero exit
# code if we can't reach this port
curl --fail -so /dev/null "http://${CONTAINERPILOT_NGINX_IP}:${PORT}/health"
