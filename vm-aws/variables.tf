variable server_name {
    type = string
    description = "Virtual machine name"
}

variable "ami" {
    type = string
    description = "Ec2 Instance AMI"
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

variable security_ports_list {
    type = list(string)
    default = [ 22 ]
    description = "Secuirty port lists"
}

variable "data_disks" {
    type = map(object({
        volume_id = string
        device_name = string
    }))
    description = "Data disks to attach (must be in the same AZ)"
    default = {}
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
    default = "ec2-user"
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
