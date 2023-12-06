# Logstash Service Module

This module contains the Kubernetes/Terraform code for a logstash deployment.

- We iterate over the prod & nonprod accounts (and automation-stack) and for each we do a logstash deployment in the observability EKS cluster. In order to do terraform module iteration, we need `terraform0.14`.
- After running this module, there should be a running logstash instance for each team and environment.
- Each logstash instance is flanked by an exporter sidecar whose metrics are scraped by prometheus
- Grafana contains dashboards to visualize the scraped metrics. This allows for an early error spotting incase of problems
- Every logstash instance is responsible for logs from three buckets for that team and environment (application, vpcflow and cloudtrail buckets).
- The list of buckets to iterate over is fetched from `log-storage/terraform/outputs.tf`.
- The resources (CPU & RAM) of each logstash instance can be modified via the module input.
