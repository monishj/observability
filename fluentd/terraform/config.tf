locals {
  service_config                         = yamldecode(file("${var.configuration_path}/${var.team_name}/aws/${var.account_env}/eks/service.yaml"))
  addons                                 = yamldecode(file("${var.configuration_path}/cloudengine/eks/addons.yaml"))
  fluentd-kubernetes-daemonset-image-tag = local.addons["versions"][local.service_config.control-plane.version]["fluentd-kubernetes-daemonset"]
}
