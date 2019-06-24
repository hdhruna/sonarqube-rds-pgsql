output "rds_address" {
  value = "${aws_db_instance.sonarqube-rds.address}"
}

output "rds_port" {
  value = "${aws_db_instance.sonarqube-rds.port}"
}

output "rds_username" {
  value = "${var.database_username}"
}

output "rds_password" {
  value = "${var.database_password}"
}

output "rds_database_name" {
  value = "${var.database_name}"
}

output "instance_public_ip" {
  value = "${aws_instance.sonarqube.*.public_ip}"
}
