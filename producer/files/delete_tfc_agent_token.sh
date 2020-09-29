#!/bin/bash

# requires TFCB entitlement on the organization

# Exit if any of the intermediate steps fail
set -e

# delete an agent token
curl --silent \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request DELETE \
  https://app.terraform.io/api/v2/authentication-tokens/$TOKEN_ID