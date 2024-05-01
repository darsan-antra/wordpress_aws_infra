resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Wordpress-VPC-IGW"
  }
}

resource "aws_eip" "nat1" {

  vpc                       = true
  associate_with_private_ip = "10.0.144.0"
  depends_on                = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway1" {

  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_subnet_1a.id
  tags = {
    Name = "Wordpress_NAT1"
  }
  depends_on = [aws_eip.nat1]
}

resource "aws_eip" "nat2" {
  vpc                       = true
  associate_with_private_ip = "10.0.146.0"
  depends_on                = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gateway2" {

  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_subnet_1b.id
  tags = {
    Name = "Wordpress_NAT2"
  }
  depends_on = [aws_eip.nat2]
}