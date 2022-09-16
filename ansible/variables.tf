variable "user" {
    type = string
}
variable "rsa_key_path" {
    type = string
}

variable "ip" {
    type = string
}

variable "file_path" {
    type = string
}   

variable "ansible_roles" {
    type = map(object({
        rolename = string
    }))
    default = {}
}
variable "ansible_depends" {
    description = "Check for complete run of ansible playbook with file <ansible_confi_done>.yaml.done"
    type = map(object({
        ansible_config_done = string
    }))
    default = {}
}
variable "file_only" {
    type = bool
    default = false 
}