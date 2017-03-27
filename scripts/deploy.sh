#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

# KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

EXTERNAL_URL=${EXTERNAL_URL:-https://prometheus.example.com}
eval "${KUBECTL} create configmap external-url --from-literal=url=${EXTERNAL_URL} --dry-run -o yaml" | eval "${KUBECTL} apply -f -"

CONFIG_PATH="../config"
DEPLOY_PATH="../deployments"

# eval "kubectl ${KUBECTL_PARAMS} create namespace \"${NAMESPACE}\""


# CONFIG MAPS
eval "${KUBECTL} create configmap grafana-imports --from-file=${CONFIG_PATH}/grafana-imports-cm -o json --dry-run" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap prometheus-rules --from-file=${CONFIG_PATH}/prometheus-rules-cm -o yaml --dry-run" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap alertmanager-templates --from-file=${CONFIG_PATH}/alertmanager-templates-cm -o json --dry-run" | eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap alertmanager --from-file=${CONFIG_PATH}/alertmanager-cm -o yaml --dry-run" |  eval "${KUBECTL} apply -f -"
eval "${KUBECTL} create configmap prometheus --from-file=${CONFIG_PATH}/prometheus-cm -o yaml --dry-run" |  eval "${KUBECTL} apply -f -"

for yaml in ${DEPLOY_PATH}/*.yaml; do
  eval "${KUBECTL} create -f \"${yaml}\""
done

print_green "Successfully deployed!"

eval "${KUBECTL} get pods $@"

