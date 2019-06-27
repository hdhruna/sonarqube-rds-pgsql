#!/bin/bash

# System changes
groupadd sonarqube
useradd -c "Sonar System User" -d /opt/sonarqube -g sonarqube -s /bin/bash sonarqube

echo "
* soft nofile 65536
* hard nofile 131072
* soft nproc 4096
* hard nproc 4096

" >>/etc/security/limits.conf

echo "
fs.file-max = 65536
vm.max_map_count = 262144

" >>/etc/sysctl.conf

sysctl -p

yum install java-1.8.0-openjdk -qq -y -e 0

mkdir -p /opt/sonarqube

cd /opt/sonarqube

wget -nv -q https://binaries.sonarsource.com/CommercialDistribution/sonarqube-enterprise/sonarqube-enterprise-7.8.zip

unzip -qq sonarqube-enterprise-7.8.zip

rm -rf sonarqube-enterprise-7.8.zip

chown -R sonarqube:sonarqube /opt/sonarqube

echo "Setup Completed..."
