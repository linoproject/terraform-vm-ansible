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
        destination = var.destination_path
    }

    provisioner "remote-exec" {
        inline = [
            "sudo /usr/bin/ansible-playbook /home/${var.user}/ansible/${basename(var.file_path)}",
            "mv /home/${var.user}/ansible/${basename(var.file_path)} /home/${var.user}/ansible/${basename(var.file_path)}.done"
        ]
    }
}