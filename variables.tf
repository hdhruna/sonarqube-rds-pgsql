variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "vpc_id" {
  type        = "string"
  description = "Existing VPC id"
}

variable "ami_id" {
  type        = "string"
  description = "Amazon Linux AMI"
}

variable "web_port" {}

variable "+" {
  default = "1"
}

variable "count" {
  default = "1"
}

variable "key_name" {}

variable "instance_type" {}

variable "allocated_storage" {
  description = "The storage size in GB"
  default     = "20"
}

variable "db_instance_class" {
  description = "The instance type"
}

variable "instance_user" {
  description = "The instance username"
  default     = "ec2-user"
}

variable "multi_az" {
  description = "Muti-az allowed?"
  default     = false
}

variable "database_name" {
  description = "The database name"
}

variable "database_username" {
  description = "The username of the database"
}

variable "database_password" {
  description = "The password of the database"
}
