#!/bin/bash

# NOTE: ensure TFC token is present as TOKEN env variable
# usage: ./change_ws_exec_mode.sh <YOUR TFC ORG> <YOUR TFC WORKSPACE> [Optionally additional workspaces]
TFC_ORG=$1

if [ $# -lt 2 ]
  then
    echo "Missing required arguments, see usage."
  else

# get agent pool id
AGENT_POOL_ID=$(curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/organizations/$TFC_ORG/agent-pools | jq -r '.data[0].id')

# skip first argument since already captured, and loop over each workspace
shift
for ARG in "$@"; do

TFC_WORKSPACE=$ARG

# 1. generate payload
read -r -d '' UPDATE_WORKSPACE_PAYLOAD << EOM
{
  "data": {
    "attributes": {
      "name": "$TFC_WORKSPACE",
      "execution-mode": "agent",
      "agent-pool-id": "$AGENT_POOL_ID"
    }
  },
  "type": "workspaces"
}
EOM

# 2. Update workspace
curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request PATCH \
  --data "$(echo $UPDATE_WORKSPACE_PAYLOAD)" \
  https://app.terraform.io/api/v2/organizations/$TFC_ORG/workspaces/$TFC_WORKSPACE | jq -r '.data'

done

fi
