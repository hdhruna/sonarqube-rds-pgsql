data "aws_subnet_ids" "selected" {
  vpc_id = "${var.vpc_id}"
}
