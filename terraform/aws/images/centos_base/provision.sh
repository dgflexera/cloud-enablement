#!/bin/bash
DD_KEY=$1
packages="epel-release curl wget unzip python-pip"
for package in $packages; do
	sudo yum -y install $package;
done

sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

sudo mv ~/elastic.repo /etc/yum.repos.d/elastic.repo

cd /usr/bin
sudo pip install pystache
sudo pip install argparse
sudo pip install python-daemon
sudo pip install requests
sudo pip install awscli

cd /opt
sudo curl -O https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
sudo tar -xvpf aws-cfn-bootstrap-latest.tar.gz
cd aws-cfn-bootstrap-1.4/
sudo python setup.py build
sudo python setup.py install

sudo ln -s /usr/init/redhat/cfn-hup /etc/init.d/cfn-hup
sudo chmod 775 /usr/init/redhat/cfn-hup

sudo mkdir -p /opt/aws/bin

sudo ln -s /usr/bin/cfn-hup /opt/aws/bin/cfn-hup
sudo ln -s /usr/bin/cfn-init /opt/aws/bin/cfn-init
sudo ln -s /usr/bin/cfn-signal /opt/aws/bin/cfn-signal
sudo ln -s /usr/bin/cfn-elect-cmd-leader /opt/aws/bin/cfn-elect-cmd-leader
sudo ln -s /usr/bin/cfn-get-metadata /opt/aws/bin/cfn-get-metadata
sudo ln -s /usr/bin/cfn-send-cmd-event /opt/aws/bin/cfn-send-cmd-event
sudo ln -s /usr/bin/cfn-send-cmd-result /opt/aws/bin/cfn-send-cmd-result
cat << 'EOF' | sudo tee /etc/systemd/journald.conf
ForwardToSyslog=yes
MaxLevelSyslog=info
EOF
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sudo wget https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh
sudo chmod +x install_agent.sh
sudo DD_API_KEY=$DD_KEY ./install_agent.sh
sudo setenforce 0
cat << 'EOF' | sudo tee -a /etc/dd-agent/datadog.conf
process_agent_enabled: true
non_local_traffic: true
EOF
cat << 'EOF' | sudo tee /etc/dd-agent/conf.d/disk.yaml
init_config:

instances:
  - use_mount: yes
    excluded_filesystems:
      - tmpfs
      - none
      - shm
      - tracefs
      - nsfs
      - netns
      - proc
      - overlay
EOF
sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
sudo yum -y install filebeat
sudo yum -y update
