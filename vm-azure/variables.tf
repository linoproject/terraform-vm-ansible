variable server_name {
    type = string
    description = "Virtual machine name"
}
variable subnet_id {
    description = "Backend Subnet ID (Mandatory)"
    type = string
    default = ""
}
variable subnet_frontend_id {
    description = "Optional Subnet Frontend ID"
    type = string
    default = ""
}

variable rs_location {
    type = string
    description = "Resource location default northeurope"
    default = "northeurope"
}
variable rs_name {
    description = "Resource name"
}
variable security_ports_list {
    type = list(string)
    default = [ 22 ]
    description = "Secuirty port lists"
}

variable "rsa_key_path" {
    type = string
    default = ""
  
}

variable "rsa_key_path_pvt" {
    type = string
    default = ""
  
}

variable "vm_size" {
    type = string
    default = "Standard_D2s_v3"
}

variable "os_disk_type" {
  type = string
  default = "Standard_LRS"
}

variable "os_disk_size" {
    type = string
    default = "30"
}

variable "admin_username" {
    type = string
    default = "adminuser"
}

variable "ansible" {
    type = map(object({
        file_path = string
        ansible_roles = optional(map(object({
          rolename = string
        })))
        ansible_depends = optional(map(object({
          ansible_config_done = string
        })))
    }))
    default = {}
}