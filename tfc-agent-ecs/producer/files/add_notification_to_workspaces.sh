#!/bin/bash

# NOTE: ensure TFC token is present as TOKEN env variable
# NOTE: ensure your notification token is present as HMAC_SALT env variable
# usage: ./add_notification_to_workspaces.sh <YOUR TFC ORG> <YOUR TFC WORKSPACE> [Optionally additional workspaces] <WEBHOOK_URL>
TFC_ORG=$1
WEBHOOK_URL=${@: -1}

if [ -z "$TOKEN" ]
then
      echo "Missing required environment variable TOKEN, see usage."
else

if [ -z "$HMAC_SALT" ]
then
      echo "Missing required environment variable HMAC_SALT, see usage."
else

if [ $# -lt 3 ]
  then
    echo "Missing required arguments, see usage."
  else

read -r -d '' NOTIFICATION_CONFIGURATION_PAYLOAD << EOM
{
  "data": {
    "type": "notification-configurations",
    "attributes": {
      "destination-type": "generic",
      "enabled": true,
      "name": "tfc-agent autosleeper",
      "url": "$WEBHOOK_URL",
      "token": "$HMAC_SALT",
      "triggers": [
        "run:completed",
        "run:created",
        "run:errored"
      ]
    }
  }
}
EOM

# loop over each workspaces
args=("$@")
for ((i=1; i < $#-1; i++))
{

TFC_WORKSPACE=${args[$i]}

# 1. Get workspace ID
WORKSPACE_ID="$(curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/organizations/$TFC_ORG/workspaces/$TFC_WORKSPACE | jq -r '.data.id')"

# 2. Create notification config
curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "$(echo $NOTIFICATION_CONFIGURATION_PAYLOAD)" \
  https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/notification-configurations | jq

}

fi
fi
fi