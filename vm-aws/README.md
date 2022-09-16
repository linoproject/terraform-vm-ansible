## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible"></a> [ansible](#module\_ansible) | ../ansible | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.vm_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.vm_interface_frontend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.security_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.vm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [null_resource.prepare_server](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vm_ready](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azurerm_public_ip.vm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `"adminuser"` | no |
| <a name="input_ansible"></a> [ansible](#input\_ansible) | n/a | <pre>map(object({<br>        file_path = string<br>        ansible_roles = optional(map(object({<br>          rolename = string<br>        })))<br>        ansible_depends = optional(map(object({<br>          ansible_config_done = string<br>        })))<br>    }))</pre> | `{}` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | n/a | `string` | `"30"` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | n/a | `string` | `"Standard_LRS"` | no |
| <a name="input_rs_location"></a> [rs\_location](#input\_rs\_location) | Resource location default northeurope | `string` | `"northeurope"` | no |
| <a name="input_rs_name"></a> [rs\_name](#input\_rs\_name) | Resource name | `any` | n/a | yes |
| <a name="input_rsa_key_path"></a> [rsa\_key\_path](#input\_rsa\_key\_path) | n/a | `string` | `""` | no |
| <a name="input_rsa_key_path_pvt"></a> [rsa\_key\_path\_pvt](#input\_rsa\_key\_path\_pvt) | n/a | `string` | `""` | no |
| <a name="input_security_ports_list"></a> [security\_ports\_list](#input\_security\_ports\_list) | Secuirty port lists | `list(string)` | <pre>[<br>  22<br>]</pre> | no |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | Virtual machine name | `string` | n/a | yes |
| <a name="input_subnet_frontend_id"></a> [subnet\_frontend\_id](#input\_subnet\_frontend\_id) | Optional Subnet Frontend ID | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Backend Subnet ID (Mandatory) | `string` | `""` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | n/a | `string` | `"Standard_D2s_v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | n/a |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | n/a |
| <a name="output_vm_public_ip"></a> [vm\_public\_ip](#output\_vm\_public\_ip) | n/a |
