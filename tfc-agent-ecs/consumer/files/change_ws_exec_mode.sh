#!/bin/bash

# NOTE: ensure HCP Terraform User API token is present as TOKEN env variable
# usage: ./change_ws_exec_mode.sh <YOUR HCP TERRAFORM ORG> <YOUR AGENT POOL NAME> <YOUR HCP TERRAFORM WORKSPACE> [Optionally additional workspaces]
HCP_TF_ORG=$1
AGENT_POOL_NAME=$2

if [ -z "$TOKEN" ]
then
      echo "Missing required environment variable TOKEN, see usage."
else

if [ $# -lt 3 ]
  then
    echo "Missing required arguments, see usage."
  else

# get agent pool id
AGENT_POOL_ID=$(curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/organizations/$HCP_TF_ORG/agent-pools | jq -r --arg AGENT_POOL_NAME "$AGENT_POOL_NAME" '.data[] | select(.attributes.name==$AGENT_POOL_NAME)' | jq -r '.id')

# skip first argument since already captured, and loop over each workspace
shift
for ARG in "$@"; do

HCP_TF_WORKSPACE=$ARG

# 1. generate payload
read -r -d '' UPDATE_WORKSPACE_PAYLOAD << EOM
{
  "data": {
    "attributes": {
      "name": "$HCP_TF_WORKSPACE",
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
  https://app.terraform.io/api/v2/organizations/$HCP_TF_ORG/workspaces/$HCP_TF_WORKSPACE | jq -r '.data'

done

fi
fi