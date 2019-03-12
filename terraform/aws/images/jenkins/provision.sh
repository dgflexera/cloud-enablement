#!/bin/bash -x
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
wget https://releases.hashicorp.com/packer/1.3.4/packer_1.3.4_linux_amd64.zip

sudo unzip terraform_0.11.11_linux_amd64.zip -d /usr/bin
sudo unzip packer_1.3.4_linux_amd64.zip -d /usr/bin

sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

packages="zip npm git java java-devel jenkins httpd gcc automake libffi libffi-devel go docker-ce"
for package in $packages; do
	sudo yum -y install $package;
done

sudo systemctl enable docker.service

sudo usermod -a -G docker jenkins
sudo rpm -Uvh https://github.com/feedforce/ruby-rpm/releases/download/2.6.1/ruby-2.6.1-1.el7.centos.x86_64.rpm

sudo gem install --bindir /usr/local/bin terraform_landscape

sudo pip install --upgrade aws-amicleaner future

cat <<EOF | sudo tee -a /etc/sudoers
jenkins     ALL=(ALL)        NOPASSWD: ALL
EOF
