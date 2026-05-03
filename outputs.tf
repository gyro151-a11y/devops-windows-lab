output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.public_ip.ip_address
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.rg.name
}

output "rdp_command" {
  value = "mstsc /v:${azurerm_public_ip.public_ip.ip_address}"
}

output "web_url" {
  value = "http://${azurerm_public_ip.public_ip.ip_address}"
}