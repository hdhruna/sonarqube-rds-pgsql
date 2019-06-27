#!/bin/bash -ex
# Change sonar port to a variable port number
sed -i "s/#sonar.web.port=9000/sonar.web.port=${web_port}/g" /opt/sonarqube/sonarqube-7.8/conf/sonar.properties
echo "
sonar.jdbc.username=${database_username}
sonar.jdbc.password=${database_password}
sonar.jdbc.url=jdbc:postgresql://${rds_address}:${rds_port}/${database_name}
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
#service sonarqube start && service sonarqube enable
systemctl start sonarqube && systemctl enable sonarqube