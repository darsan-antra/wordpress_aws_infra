terraform {
	required_providers {
		aws = {
		  source = "hashicorp/aws"
		  version = "~>5.46"
		}
	}
	required_version = ">= 1.2.0"
}

provider "aws" {
	access_key = var.aws_access_key
	secret_key = var.aws_secret_key
	region = "us-east-1"
}


resource "aws_vpc" "main_vpc" {
	cidr_block = "10.0.0.0/16"

	tags = {
	  Name = "Wordpress VPC"
}
}

resource "aws_subnet" "public_subnet" {

	count = 2
	vpc_id = aws_vpc.main_vpc.id
	cidr_block = element(var.public_subnet_cidrs, count.index)
	availability_zone = element(var.azs, count.index)

	tags = {
	   Name = "Public_Subnet_${count.index +1}"
}
}

resource "aws_subnet" "private_subnet_1a" {

	count = 2
	vpc_id = aws_vpc.main_vpc.id
	cidr_block = element(var.private_subnet_cidrs_1a, count.index)
	availability_zone = "us-east-1a"

	tags = {
	  Name = "Private_Subnet_1a_${count.index +1}"
}
}

resource "aws_subnet" "private_subnet_1b" {

	count = 2
	vpc_id = aws_vpc.main_vpc.id
	cidr_block = element(var.private_subnet_cidrs_1b, count.index)
	availability_zone = "us-east-1b"

	tags = {
	  Name = "Private_Subnet_1b_${count.index +1}"
}
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.main_vpc.id

	tags = {
	  Name = "Wordpress VPC IGW"
}
}

resource "aws_route_table" "internet_rt" {

	vpc_id = aws_vpc.main_vpc.id
	
	route {
	  cidr_block = "0.0.0.0/0"
	  gateway_id = aws_internet_gateway.igw.id
}
	tags = {
	  Name = "Internet Route Table"
}
}

resource "aws_eip" "nat" {

	vpc = true
}

resource "aws_nat_gateway" "nat_gateway1" {

	allocation_id = aws_eip.nat.id
	subnet_id = element(aws_subnet.public_subnet.*.id, 0)
	tags = {
	  Name = "Wordpress_NAT1"
	}
	depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway2" {

	allocation_id = aws_eip.nat.id
	subnet_id = element(aws_subnet.public_subnet.*.id, 1)
	tags= {
	  Name = "Wordpress_NAT2"
	}
	depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "public_subnet_asso" {

	count = length(var.public_subnet_cidrs)
	subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
	route_table_id = aws_route_table.internet_rt.id
}


