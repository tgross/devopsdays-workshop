#!/bin/sh
set -e

# we get the CONTAINERPILOT_WORKSHOP_IP automatically
# from ContainerPilot
curl --fail -so /dev/null "http://${CONTAINERPILOT_WORKSHOP_IP}:${PORT}"
