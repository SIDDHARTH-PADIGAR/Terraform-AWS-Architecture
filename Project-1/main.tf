terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-2"
  access_key = "AKIA**************LY5ZO"
  secret_key = "Ef2br***************9XsGWO7"
}

resource "aws_vpc" "main" {
  cidr_block     = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "PublicSGProd" {
  name        = "PublicSGProd"
  description = "Allow SSH access from anywhere"
  vpc_id      = aws_vpc.main.id

  # Define Ingress and Egress rules inline
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "PublicSGProd"
  }
}

resource "aws_security_group" "PrivateSGProd" {
  name = "PrivateSGProd"
  description = "Allows access form the VPC"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "PrivateSGProd"
  }
}

resource "aws_instance" "PublicEC2" {
  ami                    = "ami-0ae8f15ae66fe8cda"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  security_groups        = [aws_security_group.PublicSGProd.name]

  tags = {
    Name = "EC2"
  }
}

resource "aws_instance" "PrivateEC2" {
  ami                    = "ami-0ae8f15ae66fe8cda"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-subnet.id
  associate_public_ip_address = false
  security_groups        = [aws_security_group.PrivateSGProd.name]

  tags = {
    Name = "EC2"
  }
}

resource "aws_internet_gateway" "GWProd" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "GWProd"
  }
}

resource "aws_route_table" "RTProd" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.GWProd.id
  }

  tags = {
    Name = "RTProd"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "public-rt" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.RTProd.id
}

resource "aws_route_table_association" "private-rt" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.RTProd.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public-subnet.id
}


