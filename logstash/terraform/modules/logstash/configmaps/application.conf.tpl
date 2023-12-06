input {
  heartbeat {
    interval => 10
    type => "heartbeat"
  }
  s3 {
    bucket => "${bucket}"
    sincedb_path => "/tmp/sincedb/app_sincedb_file"
    role_arn => "arn:aws:iam::${account_id}:role/Logstash"
    region => "${region}"
    delete => false
    prefix => "cluster-logs"
    interval => 35 # seconds
    include_object_properties => true
    codec => "json"
    add_field => {
          "logtype" => "application"
          "account" => "${team_name}-${stage}"
        }
  }
}

filter {
  mutate {
    rename => { "message" => "log" }
    rename => {"[kubernetes][labels][app]" => "[kubernetes][labels][application]"}
  }
  json {
    source => "log"
    skip_on_invalid_json => true
    remove_field => ["log"]
  }
  date {
     match => [ "fluentd_time_ms", "ISO8601", "UNIX" ]
  }
}

output {
   amazon_es {
     hosts => ["https://${elasticsearch_endpoint}"]
     region => "${region}"
     aws_access_key_id => ''
     aws_secret_access_key => ''
     index => "${team_name}-${stage}-${account_id}-application-logs-%%{+YYYY.MM.dd}"
   }
 }
