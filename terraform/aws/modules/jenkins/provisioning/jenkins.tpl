#!/bin/bash
sudo systemctl enable jenkins.service

cat <<EOF | sudo tee -a /etc/httpd/conf/httpd.conf
Listen 8888
RewriteEngine On
EOF

#cat <<EOF | sudo tee /etc/httpd/conf.d/jenkins_redirect.conf
#<VirtualHost *:8888>
#  RewriteRule (.*) "https://${jenkins_domain}/$1" [R,L]
#</VirtualHost>
#EOF

sudo systemctl restart httpd.service

AWS_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

if mount | grep /var/lib/jenkins > /dev/null; then
	sudo echo "Jenkins EFS is mounted on /var/lib/jenkins" > /dev/ttyS0
else
	sudo echo "Mounting Jenkins Filesystem..." > /dev/ttyS0
	sudo systemctl stop jenkins.service
	sudo rm -rf /var/lib/jenkins
	sudo mkdir /var/lib/jenkins
	sudo chmod 775 /var/lib/jenkins
	sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${EFS_ID}.efs.$AWS_REGION.amazonaws.com:/ /var/lib/jenkins
	sudo chown jenkins:jenkins /var/lib/jenkins
	sudo systemctl enable jenkins.service
	sudo systemctl start jenkins.service
	sleep 120
	sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /dev/ttyS0
fi

sudo chown dd-agent:dd-agent /etc/dd-agent/conf.d/*
sleep 5
sudo systemctl enable datadog-agent.service
sudo systemctl restart datadog-agent.service
