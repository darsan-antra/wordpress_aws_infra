resource "aws_route_table" "internet_rt" {

  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Public-internet-rt-table"
  }
}

resource "aws_route" "public-internet-rt" {
  route_table_id         = aws_route_table.internet_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Private-nat-route-1"
  }
}

resource "aws_route" "nat-rt-1" {
  route_table_id         = aws_route_table.private_rt1.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Private-nat-route-2"
  }
}

resource "aws_route" "nat-rt-2" {
  route_table_id         = aws_route_table.private_rt2.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private_rt3" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Private-nat-route-3"
  }
}

resource "aws_route" "nat_rt_3" {
  route_table_id         = aws_route_table.private_rt3.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private_rt4" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Private-nat-route-4"
  }
}

resource "aws_route" "nat-rt-4" {
  route_table_id         = aws_route_table.private_rt4.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway2.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet_asso" {

  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.internet_rt.id
}

resource "aws_route_table_association" "public_subnet_1b_asso" {
  route_table_id = aws_route_table.internet_rt.id
  subnet_id      = aws_subnet.public_subnet_1b.id
}

resource "aws_route_table_association" "private_subnet_1a_asso" {
  route_table_id = aws_route_table.private_rt1.id
  subnet_id      = aws_subnet.private_subnet_1a_1.id
}

resource "aws_route_table_association" "private_subnet_1b_asso" {
  route_table_id = aws_route_table.private_rt2.id
  subnet_id      = aws_subnet.private_subnet_1b_1.id
}

resource "aws_route_table_association" "private_subnet_1a_2_ass0" {
  route_table_id = aws_route_table.private_rt3.id
  subnet_id      = aws_subnet.private_subnet_1a_2.id
}

resource "aws_route_table_association" "private_subnet_1b_2_asso" {
  route_table_id = aws_route_table.private_rt4.id
  subnet_id      = aws_subnet.private_subnet_1b_2.id
}

resource "aws_route_table" "private_db_subnet_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Private-DB_Subnet-Route-Table"
  }
}

# Add a route entry in the private subnet's route table to route traffic destined for the public subnet(s) through the NAT gateway
resource "aws_route" "private_db_subnet_to_public_subnet" {
  route_table_id         = aws_route_table.private_db_subnet_rt.id
  destination_cidr_block = aws_subnet.public_subnet_1a.cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway1.id # Replace with the ID of your NAT gateway
}

#resource "aws_route_table_association" "private_subnet_1a_2_association" {
#  route_table_id = aws_route_table.private_rt1.id
#  subnet_id      = aws_subnet.private_subnet_1a_2.id
#}
#
#
#resource "aws_route_table_association" "private_subnet_1b_2_association" {
#  route_table_id = aws_route_table.private_rt2.id
#  subnet_id      = aws_subnet.private_subnet_1b_2.id
#}