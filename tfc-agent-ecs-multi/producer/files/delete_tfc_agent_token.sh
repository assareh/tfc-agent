#!/bin/bash

# NOTE: requires TFCB entitlement on the organization
# NOTE: ensure TFC token is present as TOKEN env variable
# usage: ./delete_tfc_agent_token.sh <token-id>

TOKEN_ID=$1

if [ -z "$TOKEN" ]
then
      echo "Missing required environment variable TOKEN, see usage."
else

if [ $# -eq 0 ]
  then
    echo "Missing agent token ID."
  else

# Exit if any of the intermediate steps fail
set -e

# delete an agent token
curl -i \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request DELETE \
  https://app.terraform.io/api/v2/authentication-tokens/$TOKEN_ID

echo "An HTTP 204 indicates the Agent Token was successfully destroyed."
echo "An HTTP 404 indicates the Agent Token was not found."
fi
fi