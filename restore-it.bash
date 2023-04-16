#!/usr/bin/env bash

set -e

network_name=k8snet
inactive_network_name=$(sudo virsh net-list --inactive --name | grep ${network_name} || true)
if [[ -n ${inactive_network_name} ]]; then
    sudo virsh net-start "${inactive_network_name}"
fi
# k8snet

# sudo virsh list --all
# sudo virsh list --state-paused --state-shutoff | awk '{print $2}' | tail --lines=+3
domain_prefix='k8s-'
inactive_domains=$(sudo virsh list --state-paused --state-shutoff --name | grep ${domain_prefix} || true)
# k8s-controllers-2
# ...
echo "${inactive_domains}"
for inactive_domain in ${inactive_domains}; do
    sudo virsh start "${inactive_domain}"
done