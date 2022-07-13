### Block for Azure
terraform {
  experiments = [module_variable_optional_attrs]
}

module "VMAzureDeploy" {
    for_each = var.azure_virtual_machines
    source = "./../vm-azure"

    security_ports_list = each.value.extra_params.security_ports_list
    server_name = each.key
    subnet_id = each.value.extra_params.subnet_id
    rs_location = each.value.rs_location
    rs_name = each.value.rs_name
    rsa_key_path = each.value.extra_params.rsa_key_path
    rsa_key_path_pvt = each.value.extra_params.rsa_key_path_pvt
    ansible = each.value.extra_params.ansible
}
output "vms_azure" {
    value = tomap({
        for k,vm in module.VMAzureDeploy : k => vm
    })
}   
### Azure VM
variable "azure_virtual_machines" {
  type = map(object({
    rs_name = string
    rs_location = optional(string)
    fqdn = string
    extra_params = object({
      subnet_id = string
      subnet_frontend_id = optional(string)
      security_ports_list = optional(list(number))
      rsa_key_path = string
      rsa_key_path_pvt = string
      ansible = optional(map(object({
        file_path = string
        ansible_roles = optional(map(object({
          rolename = string
        })))
        ansible_depends = optional(map(object({
          ansible_config_done = string
        })))
      })))
    })
  }))
  default = {}
}