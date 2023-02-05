variable "control-vcpus" {
  description = "How many vcpus to allocate to the VM"
  type        = number
  default     = 1
}

variable "control-memory" {
  description = "How many MBs of RAM to allocate to the VM"
  type        = number
  default     = 512
}

variable "control-number" {
  description = "How many machines to create"
  type        = number
  default     = 1
}

variable "control-volume-size" {
  description = "How large a root disk volume (default 25GB)"
  type        = number
  default     = 16806965760
}

variable "control-image" {
  description = "Which qcow2 image to use for the base OS"
  type        = string
  nullable    = false
}

variable "control-volume-prefix" {
  description = "Prefix for volume names e.g. k8s-node..."
  default     = "k8s"
  type        = string
}

variable "nodes-vcpus" {
  description = "How many vcpus to allocate to the VM"
  type        = number
  default     = 1
}

variable "nodes-memory" {
  description = "How many MBs of RAM to allocate to the VM"
  type        = number
  default     = 512
}

variable "nodes-number" {
  description = "How many machines to create"
  type        = number
  default     = 1
}

variable "nodes-volume-size" {
  description = "How large a root disk volume (default 25GB)"
  type        = number
  default     = 26806965760
}

variable "nodes-image" {
  description = "Which qcow2 image to use for the base OS"
  type        = string
  nullable    = false
}

variable "nodes-volume-prefix" {
  description = "Prefix for volume names e.g. k8s-node..."
  default     = "k8s"
  type        = string
}

variable "ssh-public-key" {
  description = "ssh-rsa key for terraform-libvirt user"
  type        = string 
  default     = "<dummy - must be replaced via command-line option -var>"
  validation {
    condition = length(var.ssh-public-key) > 0
    error_message = "Must provide an SSH public key as a parameter"
  }
}
