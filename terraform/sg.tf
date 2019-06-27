resource "aws_security_group_rule" "allow-egress_egress_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.sonarqube.id}"
}

resource "aws_security_group" "sonarqube" {
  name        = "sonarqube"
  description = "SonarQube from VPC"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.web_port}"
    to_port     = "${var.web_port}"
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  ingress {
    from_port       = "${var.web_port}"
    to_port         = "${var.web_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sonarqube-elb.id}"]
  }

  tags {
    Name = "sonarqube"
  }
}

resource "aws_security_group" "postgresql" {
  name        = "postgresql"
  description = "RDS PostgreSQL for SonarQube"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sonarqube.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.sonarqube.id}"]
  }

  tags {
    Name = "rds-postgresql"
  }
}

resource "aws_security_group" "sonarqube-elb" {
  name   = "sonarqube-elb-sg"
  description = "SonarQube ELB"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "SonarQube ELB SG"
  }
}
