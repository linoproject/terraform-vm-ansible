### Block for Azure
terraform {
  experiments = [module_variable_optional_attrs]
}


### AWS VM
variable "aws_virtual_machines" {
  type = map(object({
    fqdn = string
    vm_size = optional(string)
    ami = optional(string)
    os_disk_type = optional(string)
    os_disk_size = optional(string)
    extra_params = object({
      subnet_id = string
      subnet_frontend_id = optional(string)
      security_ports_list = optional(list(number))
      data_disks = optional(map(object({
        volume_id = string
        device_name = string
      })))
      rsa_key_path = string
      rsa_key_path_pvt = string
      admin_username = optional(string)
      ansible = optional(map(object({
        file_path = optional(string)
        file_only = optional(bool)
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



module "VMAWSDeploy" {
    for_each = var.aws_virtual_machines
    source = "./../vm-aws"

    security_ports_list = each.value.extra_params.security_ports_list
    server_name = each.key
    ami = each.value.ami
    subnet_id = each.value.extra_params.subnet_id
    vm_size = each.value.vm_size
    os_disk_type = each.value.os_disk_type
    os_disk_size = each.value.os_disk_size
    rsa_key_path = each.value.extra_params.rsa_key_path
    rsa_key_path_pvt = each.value.extra_params.rsa_key_path_pvt
    ansible = each.value.extra_params.ansible
    admin_username = each.value.extra_params.admin_username
    data_disks = each.value.extra_params.data_disks
}
output "vms_aws" {
    value = tomap({
        for k,vm in module.VMAWSDeploy : k => vm
    })
}   
