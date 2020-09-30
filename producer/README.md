# Terraform Cloud Agent in Amazon ECS Producer Workspace

Provide values for required variables.

This workspace will require AWS credentials of some sort. A Terraform Cloud Agent token must also be provided as the terraform input variable `tfc_agent_token`.

I've included helper scripts to create and delete an agent token, however you can always create and manage these in the Terraform Cloud organization Settings.

`./files/create_tfc_agent_token.sh` will create an agent token and output the token value and token id. You must provide a Terraform Cloud organization or admin user token as the environment variable `TOKEN`. You must also provide your Terraform Cloud organization name as the environment variable `TFC_ORG`.

```
→ ./files/create_tfc_agent_token.sh
{
  "agent_token": "bpcqFQzBtu42qQ.atlasv1.3l7au3dmF8FQw8VNhJl2puzn0jlIF1zWn9zJPPs0s9q04KnzlKjWyUCvhpm3ALKUzf8",
  "agent_token_id": "at-VkQxdEWdPDeGEXd3"
}

Save agent_token_id for use in deletion script. Tokens can always be deleted from the Terraform Cloud Settings page.
```

`./files/delete_tfc_agent_token.sh` will delete an agent token with the specified agent token id. You must provide a Terraform Cloud organization or admin user token as the environment variable `TOKEN`. You must also provide the agent token id as an argument.

```
→ ./files/delete_tfc_agent_token.sh at-VkQxdEWdPDeGEXd3
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

## References
* [Terraform Cloud Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)
