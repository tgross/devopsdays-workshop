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


_prototype_provision() {
    _inventory "workshop-prototype"
    ansible-playbook -i ./inventory ./main.yml
}

_prototype_snapshot() {
    _inventory "workshop-prototype"
    # TODO
}

_workshop_deploy() {
    count="${1:-1}"
    echo "deploying $count instances..."
    # TODO
}

_inventory() {
    name="$1"
    echo '[workshop]' > inventory
    triton ip "${name}" >> inventory
}



# ---------------------------------------------------
# parse arguments

while true; do
    case $1 in
        create ) _prototype_create; _prototype_provision; exit; break;;
        provision ) _prototype_provision; exit; break;;
        snapshot ) _prototype_snapshot; exit; break;;
        up) _workshop_deploy "${@}"; exit; break;;
        *) break;;
    esac
done
