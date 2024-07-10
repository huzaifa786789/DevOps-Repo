terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_instance" "my_ec2_instance" {
  ami                         = "ami-0cff7528ff583bf9a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i hosts.ini configure_ec2.yml
    EOT
  }

  tags = {
    Name = "AnsibleConfiguredInstance"
  }
}

output "ec2_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}
