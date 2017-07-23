#!/bin/bash
set -e -o pipefail

# KVM parameters
image="ubuntu-certified-16.04"
package="k4-highcpu-kvm-7.75G"

# ---------------------------------------------------

# creates the prototype KVM instance
_prototype_create() {
    local private public
    private=$(triton network ls -l | awk -F' +' '/My-Fabric-Network/{print $1}')
    public=$(triton network ls -l | awk -F' +' '/Joyent-SDC-Public/{print $1}')
    triton instance create \
           --name="workshop-prototype" "${image}" "${package}" \
           --network="${public},${private}" \
           --tag="sdc_docker=true" \
           --script=./userscript.sh

    echo -n 'waiting for prototype to enter running state...'
    while true; do
        state=$(triton ls -l | awk '/ workshop-prototype/{print $6}')
        if [  "${state}" == 'running' ]; then
            break
        fi
        echo -n '.'
        sleep 3
    done
    echo ' running!'
}


_provision() {
    _inventory
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./inventory ./main.yml
}

_workshop_deploy() {
    count="${2:-1}"
    local private public
    private=$(triton network ls -l | awk -F' +' '/My-Fabric-Network/{print $1}')
    public=$(triton network ls -l | awk -F' +' '/Joyent-SDC-Public/{print $1}')

    echo "deploying $count instances..."
    for i in $(seq 1 $count); do
        triton instance create \
               --name="workshop-$i" "${image}" "${package}" \
               --network="${public},${private}" \
               --tag="sdc_docker=true" \
               --script=./userscript.sh
    done
}

_inventory() {
    echo 'updating inventory...'
    echo '[workshop]' > inventory
    for i in $(triton ls | awk '/workshop-/{print $1}'); do
        triton ip "$i" >> inventory
    done
}

# ---------------------------------------------------
# parse arguments

while true; do
    case $1 in
        inventory) _inventory; break;;
        create ) _prototype_create; _prototype_provision; exit; break;;
        provision ) _provision; exit; break;;
        up) _workshop_deploy "${@}"; exit; break;;
        *) break;;
    esac
done
