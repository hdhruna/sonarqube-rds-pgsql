data "template_file" "sonarqube-userdata" {
  template = "${file("${path.module}/userdata.sh.tpl")}"

  vars {
    web_port          = "${var.web_port}"
    database_name     = "${var.database_name}"
    database_username = "${var.database_username}"
    database_password = "${var.database_password}"
    rds_address       = "${aws_db_instance.sonarqube-rds.endpoint}"
    rds_port          = "${aws_db_instance.sonarqube-rds.port}"
  }
}

resource "aws_instance" "sonarqube" {
  count         = "${var.count}"
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(data.aws_subnet_ids.selected.ids, count.index)}"
  user_data     = "${data.template_file.sonarqube-userdata.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "60"
    delete_on_termination = "true"
  }

  vpc_security_group_ids = [
    "${aws_security_group.postgresql.id}",
    "${aws_security_group.sonarqube.id}",
  ]

  associate_public_ip_address = true
  source_dest_check           = true

  tags {
    Name = "${format("sonarqube-%02d", count.index + 1)}"
  }

  depends_on = ["aws_rds_cluster_instance.cluster_instances"]
}
