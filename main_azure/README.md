## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_VMAzureDeploy"></a> [VMAzureDeploy](#module\_VMAzureDeploy) | ./../vm-azure | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_virtual_machines"></a> [azure\_virtual\_machines](#input\_azure\_virtual\_machines) | ## Azure VM | <pre>map(object({<br>    rs_name = string<br>    rs_location = optional(string)<br>    fqdn = string<br>    vm_size = optional(string)<br>    os_disk_type = optional(string)<br>    os_disk_size = optional(string)<br>    extra_params = object({<br>      subnet_id = string<br>      subnet_frontend_id = optional(string)<br>      security_ports_list = optional(list(number))<br>      rsa_key_path = string<br>      rsa_key_path_pvt = string<br>      ansible = optional(map(object({<br>        file_path = string<br>        ansible_roles = optional(map(object({<br>          rolename = string<br>        })))<br>        ansible_depends = optional(map(object({<br>          ansible_config_done = string<br>        })))<br>      })))<br>    })<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vms_azure"></a> [vms\_azure](#output\_vms\_azure) | n/a |
