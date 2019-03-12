#!/bin/bash
sudo yum -y install java

sudo mv ~/logstash.repo /etc/yum.repos.d/logstash.repo

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

packages="logstash"
for package in $packages; do
	sudo yum -y install $package;
done

sudo systemctl enable logstash
