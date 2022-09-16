output "vm_id" {
    value = aws_instance.virtual_machine.id
}
output "vm_public_ip" {
    #value = data.azurerm_public_ip.vm_public_ip.ip_address #azurerm_public_ip.vm_public_ip.ip_address
    value = aws_instance.virtual_machine.public_ip
}
 
output "vm_private_ip" {
    #value = azurerm_linux_virtual_machine.virtual_machine.private_ip_address
    value = aws_instance.virtual_machine.private_ip
}
