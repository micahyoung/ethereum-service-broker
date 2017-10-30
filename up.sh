#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

USAGE="usage: ./up <broker-hostname> <broker-app-name> <service-name>"
BROKER_HOSTNAME=${1:?$USAGE}
BROKER_APP_NAME=${2:?$USAGE}
SERVICE_NAME=${3:?$USAGE}

pushd service_broker
  cf push $BROKER_APP_NAME --hostname $BROKER_HOSTNAME

  ROUTE=$(cf app $BROKER_APP_NAME | grep routes: | awk '{print $2}')
  USERNAME=$(grep 'username:' config/settings.yml | awk '{print $2}')
  PASSWORD=$(grep 'password:' config/settings.yml | awk '{print $2}')
  cf create-service-broker $SERVICE_NAME $USERNAME $PASSWORD https://$ROUTE --space-scoped
popd
