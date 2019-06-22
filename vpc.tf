data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}


data "aws_availability_zones" "available" {
  state = "available"
}