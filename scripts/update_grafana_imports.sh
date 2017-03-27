#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

#KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

CONFIG_PATH="../config"

eval "${KUBECTL} create configmap grafana-imports --from-file=${CONFIG_PATH}/grafana-imports-cm -o json --dry-run" | eval "${KUBECTL} replace -f -"

eval "${KUBECTL} apply -f ../deplyments/grafana-deploy-svc.yaml"

echo "Updated"
