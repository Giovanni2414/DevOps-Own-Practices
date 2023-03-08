output "resource_group_name" {
  value = azurerm_resource_group.first-practice-vm-rg.name
}

output "first-vm-with-terraform-ips" {
  value = [data.azurerm_virtual_machine.first-vm-with-terraform-data.private_ip_address,
  data.azurerm_virtual_machine.first-vm-with-terraform-data.public_ip_address]
}