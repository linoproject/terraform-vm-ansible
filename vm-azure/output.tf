output "vm_id" {
    value = azurerm_linux_virtual_machine.virtual_machine.id
}
output "vm_public_ip" {
    value = azurerm_public_ip.vm_public_ip.ip_address
}

