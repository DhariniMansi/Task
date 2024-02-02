provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "Dharini_vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "DhariniVPC"
  }
}

resource "aws_internet_gateway" "Dharini_igw" {
  vpc_id = aws_vpc.Dharini_vpc.id

  tags = {
    Name = "DhariniIGW"
  }
}

resource "aws_route_table" "Dharini_public_route" {
  vpc_id = aws_vpc.Dharini_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Dharini_igw.id
  }

  tags = {
    Name = "DhariniPublicRouteTable"
  }
}

resource "aws_subnet" "Dharini_public_subnet" {
  vpc_id                  = aws_vpc.Dharini_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "DhariniPublicSubnet"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "DhariniSecurityGroup"
  description = "Allow SSH traffic from my public IP"
  vpc_id      = aws_vpc.Dharini_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Dharini_ec2_instance" {
  ami                          = "ami-0277155c3f0ab2930"
  instance_type                = "t2.micro"
  key_name                     = "Task3"
  vpc_security_group_ids       = [aws_security_group.my_security_group.id]
  subnet_id                    = aws_subnet.Dharini_public_subnet.id
  associate_public_ip_address  = true

  tags = {
    Name = "DhariniEC2Instance"
  }
}

resource "aws_route_table_association" "Dharini_subnet_association" {
  subnet_id      = aws_subnet.Dharini_public_subnet.id
  route_table_id = aws_route_table.Dharini_public_route.id
}
