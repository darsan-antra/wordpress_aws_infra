

variable "public_subnet_cidrs" {

	type = list(string)
	description = "Public Subnet CIDR values"
	default = ["10.0.0.0/18", "10.0.64.0/18"]
}

variable "private_subnet_cidrs_1a" {
	
	type = list(string)
	description = "Private Subnet CIDR values of 1a"
	default = ["10.0.144.0/24", "10.0.145.0/24"]
}

variable "private_subnet_cidrs_1b" {

	type = list(string)
	description = "Private Subnet CIDR values of 1b"
	default = ["10.0.146.0/24", "10.0.147.0/24"] 

}

variable "azs" {

	type = list(string)
	description = "Availability Zones"
	default = ["us-east-1a", "us-east-1b"]
}

