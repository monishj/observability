#!/usr/bin/env bash
# The changing of Kubernetes variables for the different functions is to allow reading from the local cluster
# and pushing to the remote cluster
# Idea taken from https://www.revsys.com/tidbits/copying-kubernetes-secrets-between-namespaces/
set -eu -o pipefail
secret=${1}
namespace=${2}

# HARDCODED to local openshift for migration
get_secret() {
  KUBECONFIG=/dev/null \
  KUBERNETES_SERVICE_PORT=443 \
  KUBERNETES_SERVICE_HOST=172.30.0.1 \
    kubectl get secret ${secret} -o json --export
}

push_secret(){
  KUBECONFIG=${HOME}/.kube/config \
  KUBERNETES_SERVICE_PORT= \
  KUBERNETES_SERVICE_HOST= \
    kubectl apply --namespace=${namespace} -f -
}

get_secret | push_secret