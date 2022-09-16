terraform {
  experiments = [module_variable_optional_attrs]
}

data "aws_ami" "AmzLinuxAMI" {
    most_recent      = true
    owners           = ["amazon"]
    #architecture     = "x86_64"    

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }


    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}



locals {
  local_ansible = (var.ansible == null) ? {} : var.ansible
  local_vm_size = (var.vm_size == null) ? "t2.micro" : var.vm_size # Change here
  local_os_disk_type = (var.os_disk_type == null)? "standard": var.os_disk_type #Change here
  local_os_disk_size = (var.os_disk_size == null)? "30": var.os_disk_size
  local_ami = (var.ami == null)? data.aws_ami.AmzLinuxAMI.id : var.ami
  local_admin_username = (var.admin_username == null)? "ec2-user" : var.admin_username
}

data "aws_subnet" "pvt_subnet" {
  id = var.subnet_id
}

data "aws_vpc" "vpc" {
  id = data.aws_subnet.pvt_subnet.vpc_id
}

## Security groups
resource "aws_security_group" "vm_sg" {
    name        = "vpn_sg"
    description = "Allow Traffic to serevr ${var.server_name}"
    vpc_id      = data.aws_vpc.vpc.id

    tags = {
        Name = "sg_${var.server_name}"
    }
}

resource "aws_security_group_rule" "security_rule" {
  count = "${length(var.security_ports_list)}"
  
  type              = "ingress"
  from_port         = "${element(var.security_ports_list, count.index)}"
  to_port           = "${element(var.security_ports_list, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.vm_sg.id
}

resource "aws_security_group_rule" "egress_all" {
    type              = "egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.vm_sg.id
}


resource "aws_network_interface" "virtual_machine_interface" {
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.vm_sg.id]
}



resource "aws_key_pair" "key_pair" {
  key_name = "${var.server_name}_key"
  public_key = file(var.rsa_key_path)
}

resource "aws_instance" "virtual_machine" {
  ami           = local.local_ami 
  instance_type = local.local_vm_size
  
  key_name = aws_key_pair.key_pair.key_name

  network_interface {
    network_interface_id = aws_network_interface.virtual_machine_interface.id
    device_index         = 0
  }

  #credit_specification {
  #  cpu_credits = "unlimited"
  #}
  #associate_public_ip_address = true
  root_block_device {
    volume_type = local.local_os_disk_type
    volume_size = local.local_os_disk_size
  }

  tags = {
    "Name" = var.server_name
  }

  
}

## Attach disk
resource "aws_volume_attachment" "data-disk-attach" {

    for_each = var.data_disks

    device_name = each.value.device_name
    volume_id   = each.value.volume_id
    instance_id = aws_instance.virtual_machine.id
    force_detach = true
    skip_destroy = true
    provisioner "local-exec" {
        when   = destroy
        command = "aws ec2 stop-instances --instance-ids ${self.instance_id}"
    }
}


resource "null_resource" "vm_ready" {
  #depends_on = [
  #  azurerm_linux_virtual_machine.virtual_machine
  #]
  depends_on = [
    aws_instance.virtual_machine
  ]
  provisioner "local-exec" {
    #command = "while INSTANCE_STATE=$(az vm get-instance-view --name ${var.server_name} --resource-group ${var.rs_name} | grep \"Guest Agent is running\" | wc -l); test \"$INSTANCE_STATE\" == \"0\"; do sleep 1; echo -n '.'; done"
    #command = "return 0"
    #command = "while INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids ${aws_instance.virtual_machine.id} --output text --query 'Reservations[*].Instances[*].State.Name'); test \"$INSTANCE_STATE\" = \"pending\"; do sleep 1; echo -n '.'; done"
    command = "while INSTANCE_STATE=$(aws ec2 describe-instance-status --instance-ids ${aws_instance.virtual_machine.id} --output text --query 'InstanceStatuses[*].SystemStatus.Status'); [ \"$INSTANCE_STATE\" != \"ok\" ]; do sleep 1; echo $INSTANCE_STATE; done"
      
  }

  # provisioner "local-exec" {
  #   command = "sleep 10"
  # }
}


############## Ansible preparation

resource "null_resource" "prepare_server" {
    depends_on = [
      null_resource.vm_ready
    ]
    count = length(local.local_ansible) > 0 ? 1 : 0
    connection {
        type = "ssh"
        host = aws_instance.virtual_machine.public_ip
        user = local.local_admin_username
        private_key = file(var.rsa_key_path_pvt)
    }

    provisioner "remote-exec" {
        inline = [
            "echo Ansible stack intallation",
            "if [ -f /home/${local.local_admin_username}/ansible ]; then rm /home/${local.local_admin_username}/ansible; fi",
            "if [ ! -d /home/${local.local_admin_username}/ansible ]; then mkdir /home/${local.local_admin_username}/ansible; fi",
            "if [ ! -f /usr/bin/ansible ]; then sudo apt update -y && sudo apt install -y ansible && sleep 10; fi"
        ]
    }
}


module "ansible" {
  depends_on = [
    null_resource.prepare_server
  ]
  for_each = local.local_ansible

  source = "../ansible"
  #ip = azurerm_public_ip.vm_public_ip.ip_address
  ip = aws_instance.virtual_machine.public_ip
  #ip = data.azurerm_public_ip.vm_public_ip.fqdn
  file_path = each.value.file_path
  rsa_key_path = var.rsa_key_path_pvt
  user = local.local_admin_username
 
  ansible_roles = (each.value.ansible_roles == null) ? {} : each.value.ansible_roles
  ansible_depends = (each.value.ansible_depends == null) ? {} : each.value.ansible_depends

}