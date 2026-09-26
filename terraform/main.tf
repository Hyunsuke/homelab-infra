terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.endpoint
  api_token = var.api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"
  }
}

data "proxmox_virtual_environment_vms" "template" {
  tags = ["template"]
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node
  for_each     = var.vms

  source_raw {
    data = templatefile(
      "${path.module}/cloud-init/user_data.yaml",
      {
        hostname       = each.value.hostname
        ssh_public_key = var.ssh_public_key
      }
    )
    file_name = "${each.value.hostname}-ci.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  name      = each.value.hostname
  node_name = var.proxmox_node
  on_boot   = false
  tags      = ["terraform", "ubuntu"]

  agent {
    enabled = true
  }

  cpu {
    type    = "x86-64-v2-AES"
    cores   = each.value.cores
    sockets = 1
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    interface    = "scsi0"
    iothread     = true
    datastore_id = "local-lvm"
    size         = 10
    discard      = "on"
  }

  clone {
    vm_id = data.proxmox_virtual_environment_vms.template.vms[0].vm_id # Mon 1er template c'est Ubuntu Cloud Image
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }
}
