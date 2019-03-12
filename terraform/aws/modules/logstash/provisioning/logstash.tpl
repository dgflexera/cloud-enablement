#!/bin/bash
datadog_enabled=${datadog_enabled}
cat << EOF | sudo tee /etc/logstash/conf.d/filebeat.conf
input {
  beats {
    port => 5500
  }
}
filter {
  if "json" in [tags] {
    json {
      source => "message"
    }
    date {
      match => [ "unix_timestamp" , "UNIX" ]
      target => ["@timestamp"]
      timezone => "UTC"
      remove_field => ["timestamp"]
    }
    date {
      match => [ "timeMillis" , "UNIX_MS" ]
      target => ["@timestamp"]
      timezone => "UTC"
      remove_field => ["timestamp"]
    }
  }
  if "apache" in [tags] {
    if [source] =~ /error[_\.]log/ {
      if !("_grokparsefailure" in [tags]) {
        date {
            match => [ "timestamp" , "EEE MMM dd HH:mm:ss.SSSSSS yyyy" ]
        }
      }
    }
    if [source] =~ /access[_\.]log/ {
      grok {
          match => { "message" => "%{HTTPD_COMBINEDLOG}" }
      }
      if !("_grokparsefailure" in [tags]) {
        date {
            match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
        }
      }
    }
  }
  if "syslog" in [tags] {
    grok {
      match => { "message" => "%{SYSLOGLINE}" }
    }
    if !("_grokparsefailure" in [tags]) {
      date {
        match => [ "timestamp8601" , "ISO8601" ]
      }
    }
  }
  mutate {
    remove_field => ["@version"]
  }
}
output {
  elasticsearch { hosts => ["${es_endpoint}:80"] }
}
EOF

sudo systemctl restart logstash.service

cat << EOF | sudo tee /etc/dd-agent/conf.d/elastic.yaml
init_config:

instances:
  - url: "http://${es_endpoint}:80"
    cluster_stats: true
    pending_task_stats: false
EOF
sudo chown dd-agent:dd-agent /etc/dd-agent/conf.d/*
if [ $datadog_enabled = "true" ]; then
  sudo systemctl enable datadog-agent.service
  sudo systemctl restart datadog-agent.service
else
  echo "Datadog agent disabled" >> /dev/ttys0
  sudo systemctl stop datadog-agent.service
  sudo systemctl disable datadog-agent.service
fi
