#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

CONFIG_PATH="../config"

eval "${KUBECTL} create configmap alertmanager --from-file=${CONFIG_PATH}/alertmanager-cm -o yaml --dry-run" |  eval "${KUBECTL} replace -f -"

echo "Updated"
