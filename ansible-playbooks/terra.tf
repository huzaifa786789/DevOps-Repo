# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my_subnet"
  }
}

# Create a Security Group that allows SSH access
resource "aws_security_group" "ssh_access" {
  name        = "Allow SSH"
  description = "Allow SSH access from your IP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH"
  }
}

# Create an EC2 Instance
resource "aws_instance" "devops_instance" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "devops_instance"
  }
}

# Create an Ansible Inventory File
data "template_file" "inventory" {
  template = <<-EOT
  [ec2_instances]
  ${aws_instance.devops_instance.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/home/tk-lpt-0152/.ssh/id_rsa
  EOT
}

resource "local_file" "inventory" {
  filename = "inventory.ini"
  content  = data.template_file.inventory.rendered
}

# Run Ansible Playbook
resource "null_resource" "run_ansible" {
  depends_on = [aws_instance.devops_instance, local_file.inventory]

  provisioner "local-exec" {
    command     = "sleep 30 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini /home/tk-lpt-0152/Downloads/DevOps-Infra-Automation/ansible/configure_ec2.yml"
    working_dir = path.module
  }
}

