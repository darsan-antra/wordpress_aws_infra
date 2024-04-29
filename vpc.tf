resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Wordpress VPC"
  }
}

resource "aws_subnet" "public_subnet_1a" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.azs[0]

  tags = {
    Name = "Public_Subnet_1a"
  }
}

resource "aws_subnet" "public_subnet_1b" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.azs[1]

  tags = {
    Name = "Public_Subnet_1b"
  }
}

resource "aws_subnet" "private_subnet_1a_1" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs_1a[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private_Subnet_1a_1"
  }
}

resource "aws_subnet" "private_subnet_1a_2" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs_1a[1]
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private_Subnet_1a_2"
  }
}

resource "aws_subnet" "private_subnet_1b_1" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs_1b[0]
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private_Subnet_1b_1"
  }
}

resource "aws_subnet" "private_subnet_1b_2" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs_1b[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private_Subnet_1b_2"
  }
}