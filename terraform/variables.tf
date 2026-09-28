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

variable "vms" {
  type = map(object({
    hostname = string
    cores    = number
    memory   = number
  }))
}

variable "ssh_public_key" {
  type = string
}