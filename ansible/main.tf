### TODO make a provider


resource "null_resource" "ansible_depends" {
    
    for_each = var.ansible_depends
    connection {
        type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "while [ ! -f /home/${var.user}/ansible/${each.value.ansible_config_done}.yaml.done ]; do echo \"Must wait...\" && sleep 2; done "
        ]
    }
  
}

resource "null_resource" "roles" {    
    depends_on = [
      null_resource.ansible_depends
    ]

    for_each = var.ansible_roles

    connection {
         type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo /usr/bin/ansible-galaxy install ${each.value.rolename}"
        ]
    }
  
}

locals {
  local_ansible_file = var.file_path != null ? [var.file_path] : []
  local_ansible_file_exec = var.file_only == true ? [] : [var.file_path]
}

resource "null_resource" "ansible_file" {

    depends_on = [
      null_resource.ansible_depends,
      null_resource.roles      
    ]

    count = length(local.local_ansible_file)

    connection {
        type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }

    provisioner "file" {
        source = var.file_path
        destination = "/home/${var.user}/ansible/${basename(var.file_path)}"
    }

    
}

resource "null_resource" "ansible_file_exec" {
     depends_on = [
      null_resource.ansible_depends,
      null_resource.roles,      
      null_resource.ansible_file
    ]
    count = length(local.local_ansible_file_exec)

    connection {
        type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }
    provisioner "remote-exec" {
        inline = [
            "sudo /usr/bin/ansible-playbook /home/${var.user}/ansible/${basename(var.file_path)}",
            "mv /home/${var.user}/ansible/${basename(var.file_path)} /home/${var.user}/ansible/${basename(var.file_path)}.done"
        ]
    }
}
