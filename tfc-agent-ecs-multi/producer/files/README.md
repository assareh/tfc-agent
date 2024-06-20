### Create Agent Token script

`./create_tfc_agent_token.sh` will create an agent pool and token and output the token value and token id. You must provide a Terraform Cloud organization or admin user token as the environment variable `TOKEN`. You must also provide your Terraform Cloud organization name as an argument.

```
→ ./create_tfc_agent_token.sh hashidemos
{
  "agent_token": "bpcqFQzBtu42qQ.atlasv1.3l7au3dmF8FQw8VNhJl2puzn0jlIF1zWn9zJPPs0s9q04KnzlKjWyUCvhpm3ALKUzf8",
  "agent_token_id": "at-VkQxdEWdPDeGEXd3"
}

Save agent_token_id for use in deletion script. Tokens can always be deleted from the Terraform Cloud Settings page.
```

### Delete Agent Token script

`./delete_tfc_agent_token.sh` will delete an agent token with the specified agent token id. You must provide a Terraform Cloud organization or admin user token as the environment variable `TOKEN`. You must also provide the agent token id as an argument.

```
→ ./delete_tfc_agent_token.sh at-VkQxdEWdPDeGEXd3
HTTP/2 204
date: Wed, 30 Sep 2020 19:15:17 GMT
cache-control: no-cache
tfp-api-version: 2.3
vary: Accept-Encoding
vary: Origin
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
x-ratelimit-limit: 30
x-ratelimit-remaining: 29
x-ratelimit-reset: 0.0
x-request-id: d86dabf8-abc7-4953-efa0-65891a05b65b
x-xss-protection: 1; mode=block

An HTTP 204 indicates the Agent Token was successfully destroyed.
An HTTP 404 indicates the Agent Token was not found.
```

### Add Notification to Workspaces script

`./add_notification_to_workspaces.sh` will add the notification configuration to one or more workspaces in the organization specified. You must provide:
1. a Terraform Cloud organization or admin user token as the environment variable `TOKEN`.
2. the notification token you've configured (Terraform variable `notification_token`) as the environment variable `HMAC_SALT`.
3. the workspace(s) to which you'd like to add the notification configuration.
4. the webhook URL output from Terraform.

Example usage:
```
→ ./add_notification_to_workspaces.sh hashidemos andys-lab https://h8alki27g6.execute-api.us-west-2.amazonaws.com/test
```

Here's an example usage with the [TFE provider](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs):
```
resource "tfe_notification_configuration" "agent_lambda_webhook" {
 name                      = "tfc-agent"
 enabled                   = true
 destination_type          = "generic"
 triggers                  = ["run:created", "run:completed", "run:errored"]
 url                       = data.terraform_remote_state.tfc-agent-ecs-producer.outputs.webhook_url
 workspace_external_id     = tfe_workspace.test.id
}
```