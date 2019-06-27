# data "template_file" "sonarqube-userdata" {
#   template = "${file("${path.module}/userdata.sh.tpl")}"

#   vars {
#     web_port          = "${var.web_port}"
#     database_name     = "${var.database_name}"
#     database_username = "${var.database_username}"
#     database_password = "${var.database_password}"
#     rds_address       = "${aws_db_instance.sonarqube-rds.endpoint}"
#     rds_port          = "${aws_db_instance.sonarqube-rds.port}"
#   }
# }

data "aws_ami" "sonarqube" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["sonarqube-*"]
  }
}

resource "aws_instance" "sonarqube" {
  count = "${var.count}"

  # ami           = "${var.ami_id}"
  ami           = "${data.aws_ami.sonarqube.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(data.aws_subnet_ids.selected.ids, count.index)}"

  # user_data     = "${data.template_file.sonarqube-userdata.rendered}"
  user_data = <<EOF
#!/bin/bash -ex
# Change sonar port to a variable port number
sed -i "s/#sonar.web.port=9000/sonar.web.port=${var.web_port}/g" /opt/sonarqube/sonarqube-7.8/conf/sonar.properties
echo "
sonar.jdbc.username=${var.database_username}
sonar.jdbc.password=${var.database_password}
sonar.jdbc.url=jdbc:postgresql://${aws_db_instance.sonarqube-rds.endpoint}/${var.database_name}
sonar.search.javaOpts=-Xms2G -Xmx2G -XX:+HeapDumpOnOutOfMemoryError
sonar.web.javaAdditionalOpts=-server
" >> /opt/sonarqube/sonarqube-7.8/conf/sonar.properties

echo "
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
LimitNOFILE=65536
LimitNPROC=4096

ExecStart=/opt/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/sonarqube.service

sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonarqube/' /opt/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh
chown -R sonarqube:sonarqube /opt/sonarqube
service sonarqube start && service sonarqube enable
EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "60"
    delete_on_termination = "true"
  }

  vpc_security_group_ids = [
    "${aws_security_group.sonarqube.id}"
  ]

  associate_public_ip_address = true
  source_dest_check           = true

  tags {
    Name = "${format("sonarqube-%02d", count.index + 1)}"
  }

  depends_on = ["aws_db_instance.sonarqube-rds"]
}
