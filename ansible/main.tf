### TODO make a provider

# resource "null_resource" "wait_ec2_ready" {
#     depends_on = [
#         module.ec2_hibed
#     ]
#     provisioner "local-exec" {
#         command = "while INSTANCE_STATE=$(aws ec2 describe-instance-status --instance-ids ${module.ec2_hibed.id[0]} --output text --query 'InstanceStatuses[*].SystemStatus.Status'); [ \"$INSTANCE_STATE\" != \"ok\" ]; do sleep 1; echo $INSTANCE_STATE; done"
        
#     }
        
# }


resource "null_resource" "prepare_server" {
    connection {
        type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt update -y && sudo apt install -y ansible",
            "if [ -f /home/${var.user}/ansible ]; then rm /home/${var.user}/ansible; fi",
            "if [ ! -d /home/${var.user}/ansible ]; then mkdir /home/${var.user}/ansible; fi"
        ]
    }
}

resource "null_resource" "roles" {    
    depends_on = [
      null_resource.prepare_server
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

resource "null_resource" "ansible_depends" {
    depends_on = [
      null_resource.roles
    ]
    for_each = var.ansible_depends
    connection {
        type = "ssh"
        host = var.ip
        user = var.user
        private_key = file(var.rsa_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "while [ -f /home/${var.user}/ansible/${basename(var.file_path)}.done ]; do sleep 2; done "
        ]
    }
  
}

resource "null_resource" "ansible_file" {

    depends_on = [
      null_resource.ansible_depends
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

