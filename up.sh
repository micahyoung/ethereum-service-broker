#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

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
  cf push broker --hostname ethereum-broker

  ROUTE=$(cf app broker | grep routes: | awk '{print $2}')
  USERNAME=$(grep 'username:' config/settings.yml | awk '{print $2}')
  PASSWORD=$(grep 'password:' config/settings.yml | awk '{print $2}')
  cf create-service-broker ethereum-broker $USERNAME $PASSWORD https://$ROUTE/ --space-scoped

  cf create-service ethereum-service public ethereum-discovery
popd
