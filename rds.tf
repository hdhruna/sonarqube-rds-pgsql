resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = ["${data.aws_subnet_ids.selected.ids}"]
}

resource "aws_db_instance" "sonarqube-rds" {
  identifier           = "sonarqube-database"
  allocated_storage    = "${var.allocated_storage}"
  engine               = "postgres"
  engine_version       = "11.2"
  instance_class       = "${var.db_instance_class}"
  multi_az             = "${var.multi_az}"
  name                 = "${var.database_name}"
  username             = "${var.database_username}"
  password             = "${var.database_password}"
  publicly_accessible  = "false"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet_group.id}"

  vpc_security_group_ids = [
    "${aws_security_group.postgresql.id}",
    "${aws_security_group.sonarqube.id}",
  ]

  final_snapshot_identifier = "final-snapshot-name"
  skip_final_snapshot       = true

  tags {
    name = "RDS PostgreSQL for SonarQube"
  }

  parameter_group_name = "${aws_db_parameter_group.sonarqube-pgsql.id}"

  lifecycle {
    ignore_changes = [
      "username",
      "password",
      "snapshot_identifier",
    ]
  }
}

resource "aws_db_parameter_group" "sonarqube-pgsql" {
  name   = "sonarqube-rds-pg11"
  family = "postgres11"

  parameter {
    name  = "client_encoding"
    value = "utf8"
  }
}
