terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  local_ansible = (var.ansible == null) ? {} : var.ansible
  local_vm_size = (var.vm_size == null) ? "Standard_D2s_v3" : var.vm_size
  local_os_disk_type = (var.os_disk_type == null)? "Standard_LRS": var.os_disk_type
  local_os_disk_size = (var.os_disk_size == null)? "30": var.os_disk_size
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pubip_${var.server_name}"
  resource_group_name = var.rs_name
  location            = var.rs_location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "vm_interface" {
  name                = "vminc_${var.server_name}"
  location            = var.rs_location
  resource_group_name = var.rs_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_public_ip.id
  }
}
resource "azurerm_network_interface" "vm_interface_frontend" {
  count = var.subnet_frontend_id != "" ? 1 : 0

  name                = "vminc_fe_${var.server_name}"
  location            = var.rs_location
  resource_group_name = var.rs_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_frontend_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                = var.server_name
  resource_group_name = var.rs_name
  location            = var.rs_location
  size                = local.local_vm_size
  admin_username      = var.admin_username
  
  
  network_interface_ids = [
    azurerm_network_interface.vm_interface.id
  ]

  

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.rsa_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.local_os_disk_type
    disk_size_gb = local.local_os_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

 
}

resource "null_resource" "vm_ready" {
  depends_on = [
    azurerm_linux_virtual_machine.virtual_machine
  ]
  provisioner "local-exec" {
    command = "while INSTANCE_STATE=$(az vm get-instance-view --name ${var.server_name} --resource-group ${var.rs_name} | grep \"Guest Agent is running\" | wc -l); test \"$INSTANCE_STATE\" == \"0\"; do sleep 1; echo -n '.'; done"
      
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "azurerm_network_security_group" "security_group" {
  name                = "${var.server_name}-sg"
  resource_group_name = var.rs_name
  location            = var.rs_location
}

resource "azurerm_network_security_rule" "security_rule" {
  count = "${length(var.security_ports_list)}"

  name                       = "sg-rule-${var.server_name}-${count.index}"
  direction                  = "Inbound"
  access                     = "Allow"
  priority                   = (100 * (count.index + 1))
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "${element(var.security_ports_list, count.index)}"
  protocol                   = "TCP"

  resource_group_name         = var.rs_name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

data "azurerm_public_ip" "vm_public_ip" {
  depends_on = [
    azurerm_linux_virtual_machine.virtual_machine
  ]
  name                = "pubip_${var.server_name}"
  resource_group_name = var.rs_name
}


############## Ansible preparation

resource "null_resource" "prepare_server" {
    depends_on = [
      null_resource.vm_ready
    ]
    count = length(local.local_ansible) > 0 ? 1 : 0
    connection {
        type = "ssh"
        host = data.azurerm_public_ip.vm_public_ip.ip_address
        user = var.admin_username
        private_key = file(var.rsa_key_path_pvt)
    }

    provisioner "remote-exec" {
        inline = [
            "echo Ansible stack intallation",
            "if [ -f /home/${var.admin_username}/ansible ]; then rm /home/${var.admin_username}/ansible; fi",
            "if [ ! -d /home/${var.admin_username}/ansible ]; then mkdir /home/${var.admin_username}/ansible; fi",
            "if [ ! -f /usr/bin/ansible ]; then sudo apt update -y && sudo apt install -y ansible && sleep 10; fi"
        ]
    }
}


module "ansible" {
  depends_on = [
    null_resource.prepare_server
  ]
  for_each = local.local_ansible

  source = "../ansible"
  #ip = azurerm_public_ip.vm_public_ip.ip_address
  ip = data.azurerm_public_ip.vm_public_ip.ip_address
  #ip = data.azurerm_public_ip.vm_public_ip.fqdn
  file_path = each.value.file_path
  rsa_key_path = var.rsa_key_path_pvt
  user = var.admin_username
 
  ansible_roles = (each.value.ansible_roles == null) ? {} : each.value.ansible_roles
  ansible_depends = (each.value.ansible_depends == null) ? {} : each.value.ansible_depends

}