#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

USAGE="usage: ./up <broker-hostname> <broker-app-name> <service-name>"
BROKER_HOSTNAME=${1:?$USAGE}
BROKER_APP_NAME=${2:?$USAGE}
SERVICE_NAME=${3:?$USAGE}
#for app in $(cf services | grep ethereum-log-collector | awk '{print $3}'); do
#  cf unbind-service $app ethereum-log-collector
#done
#for app in $(cf services | grep ethereum-discovery | awk '{print $3}'); do
#  cf unbind-service $app ethereum-log-collector
#done
#cf delete-service -f ethereum-log-collector
#cf delete-service -f ethereum-discovery
#cf delete-service-broker -f ethereum-broker
#cf delete -f broker

pushd service_broker
  cf push $BROKER_APP_NAME --hostname $BROKER_HOSTNAME

  ROUTE=$(cf app $BROKER_APP_NAME | grep routes: | awk '{print $2}')
  USERNAME=$(grep 'username:' config/settings.yml | awk '{print $2}')
  PASSWORD=$(grep 'password:' config/settings.yml | awk '{print $2}')
  cf create-service-broker $SERVICE_NAME $USERNAME $PASSWORD https://$ROUTE --space-scoped
popd
