

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Change to your preferred availability zone

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-06c68f701d8090592"  # Change to your preferred AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "web-instance"
  }
}
