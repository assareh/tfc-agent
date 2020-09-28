#!/bin/bash

# requires TFCB entitlement on the organization

# Exit if any of the intermediate steps fail
set -e

# Extract "foo" and "baz" arguments from the input into
# FOO and BAZ shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "TFC_ORG=\(.tfc_org) TOKEN=\(.tfc_token)"')"

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
      "description":"api"
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
  https://app.terraform.io/api/v2/agent-pools/$AGENT_POOL_ID/authentication-tokens | jq -r '.data.attributes.token')

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg agent_token "$AGENT_TOKEN" '{"agent_token":$agent_token}'