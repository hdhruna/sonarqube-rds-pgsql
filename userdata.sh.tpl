#!/bin/bash

### sonarqube_linux_installation.sh
# This shellscript installs sonarqube on a linux machine, specifically on a x86_64 Linux system

echo Starting SonarQube installation procedure



# System changes
echo "
* soft nofile 65536
* hard nofile 131072
* soft nproc 4096
* hard nproc 4096
" >> /etc/security/limits.conf
sysctl -w fs.file-max=65536
sysctl -w vm.max_map_count=262144


# Assign variables
# port_number=${web_port}

# Remove default Java and install version known to work with SonarQube
yum remove java -y
yum install java-1.8.0-openjdk-devel -y

# Get the installation zip file and unzip it
# wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.6.zip
wget https://binaries.sonarsource.com/CommercialDistribution/sonarqube-enterprise/sonarqube-enterprise-7.8.zip
mkdir /etc/sonarqube
unzip -qq sonarqube-enterprise-7.8.zip -d /etc/sonarqube/

cat <<EOF > /tmp/sonar
#!/bin/bash
#
# rc file for SonarQube
#
# chkconfig: 345 96 10
# description: SonarQube system (www.sonarsource.org)
#
### BEGIN INIT INFO
# Provides: sonar
# Required-Start: $network
# Required-Stop: $network
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: SonarQube system (www.sonarsource.org)
# Description: SonarQube system (www.sonarsource.org)
### END INIT INFO

/usr/bin/sonar \$*
EOF


# setup sonarqube to run as a service
mv /tmp/sonar /etc/init.d/sonar
ln -s  /etc/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh /usr/bin/sonar
chmod 755 /etc/init.d/sonar
chown root:root /etc/init.d/sonar
chkconfig --add sonar
sed -i 's/wrapper.java.command=java/wrapper.java.command=\/usr\/lib\/jvm\/jre\/bin\/java/' /etc/sonarqube/sonarqube-7.8/conf/wrapper.conf

# Change sonar port to a variable port number
sed -i "s/#sonar.web.port=9000/sonar.web.port=${web_port}/g" /etc/sonarqube/sonarqube-7.8/conf/sonar.properties
echo "
sonar.jdbc.username=${database_username}
sonar.jdbc.password=${database_password}
sonar.jdbc.url=jdbc:postgresql://${rds_address}:${rds_port}/${database_name}
sonar.search.javaOpts=-Xms2G -Xmx2G -XX:+HeapDumpOnOutOfMemoryError
" >> /etc/sonarqube/sonarqube-7.8/conf/sonar.properties

# Create sonar user and change file permissions
useradd sonar
sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/' /etc/sonarqube/sonarqube-7.8/bin/linux-x86-64/sonar.sh
chown -R sonar:sonar /etc/sonarqube

# service sonar start

/usr/bin/sonar start

# Show logs for verifying setup is successful
sleep 10s
cat /etc/sonarqube/sonarqube-7.8/logs/sonar.log
# cat /etc/sonarqube/sonarqube-enterprise-7.8/logs/es.log

echo SonarQube installation procedure completed