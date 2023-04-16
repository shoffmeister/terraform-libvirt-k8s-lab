#!/usr/bin/env bash

set -e

###############

pushd ./terraform/k8s

terraform_libvirt_keyfile=~/.ssh/terraform-libvirt
mapfile -t terraform_libvirt_publickey_content < <(cat "${terraform_libvirt_keyfile}.pub")

echo "Using SSH public key: ${terraform_libvirt_publickey_content[1]}"

terraform destroy -auto-approve

cloud_image_url='file:///home/stefan/Downloads/jammy-server-cloudimg-amd64.img'

terraform apply -auto-approve \
    -var "ssh-public-key=${terraform_libvirt_publickey_content[1]}" \
    -var "control-image=${cloud_image_url}" \
    -var "nodes-image=${cloud_image_url}"

popd

###############

pushd ansible

ansible-playbook --verbose --inventory hosts \
    bootstrap.yaml

popd

###############

pushd ansible

ansible-playbook --verbose --inventory hosts \
    join-worker-nodes.yaml

popd

###############

pushd ansible

ansible-playbook --verbose --inventory hosts \
    local-config.yaml

popd

###############

kubectl --kubeconfig ./ansible/admin.conf \
    get pods --all-namespaces
