#!/bin/bash

# System changes
echo "
* soft nofile 65536
* hard nofile 131072
* soft nproc 4096
* hard nproc 4096

" >> /etc/security/limits.conf
# sysctl -w fs.file-max=65536
# sysctl -w vm.max_map_count=262144

echo "
fs.file-max = 65536
vm.max_map_count = 262144

" >> /etc/sysctl.conf

sysctl -p

apt -qq update < /dev/null > /dev/null && DEBIAN_FRONTEND=noninteractive apt -qq upgrade -y < /dev/null > /dev/null 

DEBIAN_FRONTEND=noninteractive apt -qq install openjdk-11-jre-headless unzip -y < /dev/null > /dev/null 

adduser --system --no-create-home --group --disabled-login sonarqube

mkdir /opt/sonarqube

cd /opt/sonarqube

wget -nv -q https://binaries.sonarsource.com/CommercialDistribution/sonarqube-enterprise/sonarqube-enterprise-7.8.zip

unzip -qq sonarqube-enterprise-7.8.zip

rm -rf sonarqube-enterprise-7.8.zip

chown -R sonarqube:sonarqube /opt/sonarqube

# # Change sonar port to a variable port number
# sed -i "s/#sonar.web.port=9000/sonar.web.port=${web_port}/g" /opt/sonarqube/sonarqube-7.8/conf/sonar.properties
# echo "
# sonar.jdbc.username=${database_username}
# sonar.jdbc.password=${database_password}
# sonar.jdbc.url=jdbc:postgresql://${rds_address}:${rds_port}/${database_name}
# sonar.search.javaOpts=-Xms2G -Xmx2G -XX:+HeapDumpOnOutOfMemoryError
# sonar.web.javaAdditionalOpts=-server
# " >> /opt/sonarqube/sonarqube-7.8/conf/sonar.properties

# echo "
# [Unit]
# Description=SonarQube service
# After=syslog.target network.target

# [Service]
# Type=forking

# ExecStart=/opt/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh start
# ExecStop=/opt/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh stop

# User=sonarqube
# Group=sonarqube
# Restart=always

# [Install]
# WantedBy=multi-user.target
# " > /etc/systemd/system/sonarqube.service
