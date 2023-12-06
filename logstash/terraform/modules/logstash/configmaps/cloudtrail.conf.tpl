input {
  heartbeat {
    interval => 10
    type => "heartbeat"
  }
  s3 {
    bucket => "${bucket}"
    sincedb_path => "/tmp/sincedb/cloudtrail_sincedb_file"
    role_arn => "arn:aws:iam::${account_id}:role/Logstash"
    region => "${region}"
    delete => false
    interval => 35 # seconds
    prefix => "AWSLogs/${account_id}/CloudTrail/"
    include_object_properties => true
    codec => "cloudtrail"
    add_field => {
      "logtype" => "cloudtrail"
      "account" => "${team_name}-${stage}"
    }
  }
}

output {
    amazon_es {
      hosts => ["https://${elasticsearch_endpoint}"]
      region => "${region}"
      aws_access_key_id => ''
      aws_secret_access_key => ''
      index => "${team_name}-${stage}-${account_id}-cloudtrail-logs-%%{+YYYY.MM.dd}"
    }
}
