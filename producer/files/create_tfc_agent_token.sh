#!/bin/bash

# NOTE: requires TFCB entitlement on the organization
# NOTE: ensure TFC token is present as TOKEN env variable
# usage: ./create_tfc_agent_token.sh <YOUR TFC ORG>
TFC_ORG=$1

if [ $# -eq 0 ]
  then
    echo "Missing TFC organization."
  else
# Exit if any of the intermediate steps fail
set -e

# this was to be used to create the initial agent pool, but may not be required at this time
# cat << EOM > payload.json
# {
#     "data": {
#         "type": "agent-pools"
#     }
# }
# EOM

# create an agent pool
# AGENT_POOL_ID=$(curl \
#   --header "Authorization: Bearer $TOKEN" \
#   --header "Content-Type: application/vnd.api+json" \
#   --request POST \
#   --data @payload.json \
#   https://app.terraform.io/api/v2/organizations/$TFC_ORG/agent-pools | jq -r '.data.id')

# get agent pool id
AGENT_POOL_ID=$(curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/organizations/$TFC_ORG/agent-pools | jq -r '.data[0].id')

cat << EOM > payload.json
{
  "data": {
    "type": "authentication-tokens",
    "attributes": {
      "description":"via-api-for-aws-ecs"
    }
  }
}
EOM

# create an agent token
AGENT_TOKEN=$(curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @payload.json \
  https://app.terraform.io/api/v2/agent-pools/$AGENT_POOL_ID/authentication-tokens | jq -r '.data')

AGENT_TOKEN_VALUE="$(echo $AGENT_TOKEN | jq -r '.attributes.token')"
AGENT_TOKEN_ID="$(echo $AGENT_TOKEN | jq -r '.id')"

# Safely produce a JSON object containing the result values.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg agent_token "$AGENT_TOKEN_VALUE" --arg agent_token_id "$AGENT_TOKEN_ID" '{"agent_token":$agent_token, "agent_token_id":$agent_token_id}'

echo ""
echo "Save agent_token_id for use in deletion script. Tokens can always be deleted from the Terraform Cloud organization Settings page."
fi