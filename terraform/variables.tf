variable "endpoint" {
  type = string
}

variable "api_token" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "proxmox1"
}

# variable "vm_hostname" {
#   type    = string
#   default = "tf-demo"
# }

variable "vms" {
  # type = string
  # default = "k8s-cp-1"
  type = map(object({
    hostname = string
    cores    = number
    memory   = number
  }))
}

variable "ssh_public_key" {
  type = string
}