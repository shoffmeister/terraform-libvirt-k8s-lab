#!/usr/bin/env bash

set -e

# sudo virsh list --all
# sudo virsh list --state-paused --state-shutoff | awk '{print $2}' | tail --lines=+3
domain_prefix='k8s-'
active_domains=$(sudo virsh list --name | grep ${domain_prefix} || true)
# k8s-controllers-2
# ...
echo "${active_domains}"
for active_domain in ${active_domains}; do
    sudo virsh shutdown "${active_domain}"
done

# unclear how to stop network
# virsh net-stop does not exist
# network_name=k8snet
# active_network_name=$(sudo virsh net-list --name | grep ${network_name} || true)
# if [[ -n ${active_network_name} ]]; then
#     sudo virsh net-stop "${active_network_name}"
# fi
# # k8snet

