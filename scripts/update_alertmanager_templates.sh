#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

#KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

CONFIG_PATH="../config"

eval "${KUBECTL} create configmap alertmanager-templates --from-file=${CONFIG_PATH}/alertmanager-templates-cm -o json --dry-run" | eval "${KUBECTL} replace -f -"

echo "Updated"
