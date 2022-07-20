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



resource "null_resource" "ansible_file" {

    depends_on = [
      null_resource.ansible_depends,
      null_resource.roles      
    ]

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

    provisioner "remote-exec" {
        inline = [
            "sudo /usr/bin/ansible-playbook /home/${var.user}/ansible/${basename(var.file_path)}",
            "mv /home/${var.user}/ansible/${basename(var.file_path)} /home/${var.user}/ansible/${basename(var.file_path)}.done"
        ]
    }
}

