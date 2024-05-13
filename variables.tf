variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {

  type        = string
  description = "Name of the project"
  default     = "wordpress"
}

variable "public_subnet_cidrs" {

  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.0.0/18", "10.0.64.0/18"]
}

variable "private_subnet_cidrs_1a" {

  type        = list(string)
  description = "Private Subnet CIDR values of 1a"
  default     = ["10.0.144.0/24", "10.0.145.0/24"]
}

variable "private_subnet_cidrs_1b" {

  type        = list(string)
  description = "Private Subnet CIDR values of 1b"
  default     = ["10.0.146.0/24", "10.0.147.0/24"]

}

variable "ssh_pubkey_file" {
  description = "path to the ssh key "
  default     = "~/.ssh/aws/aws_key.pub"
}

variable "azs" {

  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "autoscale_min" {
  description = "Minimum number of instances"
  default     = "2"
}

variable "autoscale_max" {
  description = "Maximum number of instances"
  default     = "2"
}

variable "autoscale_desired" {
  description = "Desired number of healthy instances"
  default     = "2"
}

variable "launch_config_ec2_ami" {
  description = "AMI Id of the instance to use while launching"
  default     = "ami-04ff98ccbfa41c9ad"
}

variable "db_instance_ami" {
  description = "AMI id of the db instance with preinstalled Apache, MySQL, PHP, Ruby"
  default     = "ami-05efd9e66ddc3cf4b"
}
variable "aurora_cluster_identifier" {
  description = "Name to identify the cluster"
  default     = "wordpress-cluster"
}

variable "database_name" {
  description = "Name of the aurora database"
  default     = "wordpress-db"
}

variable "secrets_manager_name" {
  description = "Name of the secret password of the database"
  default     = "test-db-password1429"
}
variable "aurora_master_username" {
  description = "User name to login to the aurora database"
  default     = "marni4"
}

variable "aurora_allocated_storage" {
  description = "Allocated storage type to the aurora db"
  default     = "10"
}

variable "mysql_pass" {
  description = "MySQL db root password"
  default     = "root"
}

variable "table_prefix" {
  description = "table prefix"
  default = "$table_prefix"
}

