#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

#KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

CONFIG_PATH="../config"

eval "${KUBECTL} create configmap prometheus-rules --from-file=${CONFIG_PATH}prometheus-rules-cm -o yaml --dry-run" | eval "${KUBECTL} replace -f -"

echo "Updated"
