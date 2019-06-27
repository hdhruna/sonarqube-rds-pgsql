resource "aws_elb" "sonarqube-elb" {
  name                      = "sonarqube-elb"
  subnets                   = ["${element(data.aws_subnet_ids.selected.ids, count.index)}"]
  security_groups           = ["${aws_security_group.sonarqube-elb.id}"]
  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "TCP:${var.web_port}"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.web_port}"
    instance_protocol = "http"
  }

  tags {
    Name = "SonarQube ELB"
  }

  depends_on = ["aws_instance.sonarqube"]
}

resource "aws_elb_attachment" "sonarqube-elb-attachment" {
  elb      = "${aws_elb.sonarqube-elb.id}"
  instance = "${aws_instance.sonarqube.id}"

  depends_on = ["aws_elb.sonarqube-elb"]
}
