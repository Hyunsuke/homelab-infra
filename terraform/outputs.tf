output "vm_ipv4" {
  # value = proxmox_virtual_environment_vm.vm.ipv4_addresses
  value = {
    for name, vm in proxmox_virtual_environment_vm.vm :
    name => vm.ipv4_addresses
  }
}