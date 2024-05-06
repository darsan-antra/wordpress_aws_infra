
output "vpc_id" {

  description = "ID of the wordpress VPC"
  value       = aws_vpc.main_vpc.id
}


output "public_subnet_1a_cidr" {

  description = "CIDR range of public subnets in wordpress VPC"
  value       = aws_subnet.public_subnet_1a.cidr_block
}

output "public_subnet_1b_cidr" {

  description = "CIDR range of public subnets in wordpress VPC"
  value       = aws_subnet.public_subnet_1b.cidr_block
}

output "private_subnet_1a_1_cidr" {

  description = "CIDR block of private subnets in wordpress VPC"

  value = aws_subnet.private_subnet_1a_1.cidr_block
}

output "private_subnet_1a_2_cidr" {

  description = "CIDR block of private subnets in wordpress VPC"

  value = aws_subnet.private_subnet_1a_2.cidr_block
}

output "private_subnet_1b_1_cidr" {

  description = "CIDR block of private subnets in wordpress VPC 1b AZ"

  value = aws_subnet.private_subnet_1b_1.cidr_block
}

output "private_subnet_1b_2_cidr" {

  description = "CIDR block of private subnets in wordpress VPC 1b AZ"

  value = aws_subnet.private_subnet_1b_2.cidr_block
}

output "loadbalancer_dns" {
  description = "DNS of the load balancer"

  value = aws_lb.wordpress-lb.dns_name
}

#output "rds_db_hostname" {
#  description = "Database Host of the the wordpress"
#  value = aws_db_instance.wordpress_db.address
#}
