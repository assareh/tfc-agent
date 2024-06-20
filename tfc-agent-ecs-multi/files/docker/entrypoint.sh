#!/bin/bash

aws=$(curl -s "http://169.254.170.2${AWS_CONTAINER_CREDENTIALS_RELATIVE_URI}")

export AWS_ACCESS_KEY_ID=$(echo $aws|jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $aws|jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $aws|jq -r '.Token')
export AWS_ROLE_ARN=$(echo $aws|jq -r '.RoleArn')

echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
echo "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"
echo "AWS_ROLE_ARN=$AWS_ROLE_ARN"

exec /bin/tfc-agent "$@"