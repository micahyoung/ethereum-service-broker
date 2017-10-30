#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

USAGE="usage: ./up <broker-app-name> <service-broker-name>"
BROKER_APP_NAME=${1:?$USAGE}
SERVICE_BROKER_NAME=${2:?$USAGE}

SERVICE_NAME=$(grep -E '^      name:' service_broker/config/settings.yml | awk '{print $2}')
for app in $(cf services | grep $SERVICE_NAME | awk '{print $3}'); do
  cf unbind-service $app $SERVICE_NAME
done
cf delete-service -f $SERVICE_NAME
cf delete-service-broker -f $SERVICE_BROKER_NAME
cf delete -f -r $BROKER_APP_NAME
