# Terraform + libvirt + Ansible = HA Kubernetes Lab

![Image](https://raw.githubusercontent.com/jamonation/terraform-libvirt-k8s-lab/assets/terraform-libvirt-k8s-lab.png)

## Introduction

A home lab is a great way to explore and learn about different tools,
architectures, and development methods.

The idea behind this repository is to use Terraform and Ansible to build a
local Kubernetes cluster that is more extensible, and closer to a production
 architecture than many of the typical single-machine example environments.

## About

This repository contains all the Terraform modules and Ansible roles that you
need to build a local [High Availability Kubernetes cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/)
that you can experiment with.

The Terraform modules use the [`libvirt` terraform provider](https://github.com/dmacvicar/terraform-provider-libvirt)
to provision a virtual network and virtual machines, so you'll need to
 be running `libvirtd` on Linux to be able to use this repository.

The stacked Kubernetes control plane is managed using
[HAProxy and Keepalived]([<https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#keepalived-and-haproxy)>
running as static pods on the control plane VMs.

## Requirements

To use this repository you will need the following on your local machine:

* Linux
* Ansible
* Terraform >= v0.13
* libvirt with a `default` storage pool - the
  [`network module`](https://github.com/jamonation/terraform-libvirt-k8s-lab/tree/main/terraform/modules/network)
  in this repository will define a network for you
* [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt)
* Enough CPU, RAM, and disk space to run two libvirt guests - the more the better!

```sh
need to run virt-manager once to create default pool in /var
somehow the default network was not set to start and not to autostart -> virt-manager

virsh pool-list

pool_dir=~/.local/share/libvirt/images
mkdir -p ${pool_dir}
virsh pool-define-as --name default --type dir --target ${pool_dir} 

virsh pool-start default
virsh pool-autostart default

grep -E --color '(vmx|svm)' /proc/cpuinfo
sudo systemctl restart libvirtd
```

## Using this repository

`terraform` will need to be run with an SSH key;

```sh
terraform_libvirt_keyfile=~/.ssh/terraform-libvirt

# Must be RSA, really ought to have no passphrase
# for Ansible to work conveniently (except if an agent
# keeps the key around)
ssh-keygen -f "${terraform_libvirt_keyfile}" -t rsa -N ""

terraform_libvirt_publickey_content=($(cat "${terraform_libvirt_keyfile}.pub"))

cat >> ~/.ssh/config <<EOT

Host 10.17.3.*
  StrictHostKeyChecking no
  User terraform-libvirt
  IdentityFile ${terraform_libvirt_keyfile}
  AddKeysToAgent yes
  PreferredAuthentications publickey
EOT
```

The various `variables.tf` files TODO:

```hcl
variable "ssh-public-key" {
  description = "ssh-rsa key for terraform-libvirt user"
  default     = ""
}
```

```sh
pushd ./terraform/k8s

terraform init

terraform apply -var "ssh-public-key=${terraform_libvirt_publickey_content[1]}"

popd
```

Running the above with no additional variable arguments will create
5 Kubernetes nodes - 3 control plane, and 2 nodes for workloads.
Each will use 2 CPUs, and have 2GB of RAM allocated.

Once the VMs are up,

```sh
pushd ansible

ansible-playbook -i hosts bootstrap.yaml
```

to bootstrap the Kubernetes control plane on one VM.
The role will also generate a token for other `control-plane` nodes and will use
that on the remaining nodes to join them to the cluster.

Kubernetes is accessed using a virtual IP that is managed by HAProxy and
Keepalived. The IP address is `10.17.3.254`.

Running `ansible-playbook -i hosts local-config.yaml` will copy `admin.conf` to
the playbook directory to be used along with `kubectl` as
`kubectl --kubeconfig admin.conf get namespace`.

Each of the VMs has a static IP address for ease of access and keeping track of
what lives where. The machines (in the default configuration) are:

```text
k8s-controller-2 10.17.3.2
k8s-controller-3 10.17.3.3
k8s-controller-4 10.17.3.4

k8s-nodes-2 10.17.3.10
k8s-nodes-3 10.17.3.11
```

The guest hostname are indexed roughly according to their IP address -
since `10.17.3.1` is the gateway, the nodes and IPs start at `2`.

## Helpful resources, kudos, and credits

[How To Provision VMs on KVM with Terraform](https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/) -
a great resource to consult if you're just getting started with Terraform and KVM.

[Using the Libvirt Provisioner With Terraform for KVM](https://blog.ruanbekker.com/blog/2020/10/08/using-the-libvirt-provisioner-with-terraform-for-kvm/) -
a more advanced example than the first

[Dynamic Cloud-Init Content with Terraform File Templates](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/) -
templating `cloud-init` data wouldn't have been possible
without this invaluable explanation.

The [`terraform-provider-libvirt` documentation](https://github.com/dmacvicar/terraform-provider-libvirt)
of course!

[How To Create a Kubernetes Cluster Using Kubeadm on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04) -
this tutorial formed the basis for the Ansible roles
