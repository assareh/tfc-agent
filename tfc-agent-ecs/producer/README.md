# Terraform Cloud Agent in Amazon ECS Producer Workspace

This workspace will require AWS access/credentials to provision.

## Usage

### Variables
Please provide values for the following required [variables](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables):
* `prefix`: a name prefix to add to the resources
* `tfc_agent_token`: The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud. (See the next section for how to create this.)

In addition, I recommend that you review all other variables and configure their values according to your specifications. You can adjust the resource allocations for the agent task with `task_cpu`, `task_mem`, `task_def_cpu`, and `task_def_mem`. (Refer to the [AWS docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size) for the supported sizes.) As of this writing, the terraform run environment built in to Terraform Cloud provides 2 cores and 2GB of RAM. However, I have used the agent with as little as 256MB of RAM. YMMV

`ttl` and `common_tags` are used only for tagging and are completely optional.

### Terraform Cloud Agent Token
An agent token is a secret value that is used to uniquely identify your agents and allow them to register themselves with your Terraform Cloud organization. Please refer to the [documentation](https://www.terraform.io/docs/cloud/agents/index.html#managing-agent-pools) for an explanation of what an agent pool is and how to create an agent token in the Terraform Cloud Settings console.

Additionally, these may now be created and managed with Terraform due to the addition of the following resources and data sources in version 0.24.0 of the [tfe provider](https://registry.terraform.io/providers/hashicorp/tfe/latest):
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_pool) resource
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/agent_pool) data source
* [`tfe_agent_token`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_token) resource

Prior to the addition of these resources to the tfe provider, I had written helper scripts to create and revoke agent tokens using the Terraform Cloud API. Those scripts remain available [here](files/README.md).

## Autoscaling tfc-agent with a Lambda Function
I've included a Lambda function that, when combined with [Terraform Cloud notifications](https://www.terraform.io/docs/cloud/workspaces/notifications.html), enables autoscaling the number of Terraform Cloud Agents running.

![notification_config](./files/notification_config.png)

To use it, you'll need to:
1. Configure the `desired_count` and `max_count` Terraform variables as desired. `desired_count` sets the baseline number of agents to always be running. `max_count` sets the maximum number of agents allowed to be running at one time.

2. Configure a [generic notification](https://www.terraform.io/docs/cloud/workspaces/notifications.html#creating-a-notification-configuration) on each Terraform Cloud workspace that will be using an agent (workspace [execution mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) set to `Agent`). I've included a helper script that will create them for you, however you can always create and manage these in the Terraform Cloud workspace Settings. You could also use the [Terraform Enterprise provider](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs).

That's it! When a run is queued, Terraform Cloud will send a notification to the Lambda function, increasing the number of running agents. When the run is completed, Terraform Cloud will send another notification to the Lambda function, decreasing the number of running agents.

Note: [Speculative Plans](https://www.terraform.io/docs/cloud/run/index.html#speculative-plans) do not trigger this autoscaling.

### Add Notification to Workspaces script

`./files/add_notification_to_workspaces.sh` will add the notification configuration to one or more workspaces in the organization specified. You must provide:
1. a Terraform Cloud organization or admin user token as the environment variable `TOKEN`.
2. the notification token you've configured (Terraform variable `notification_token`) as the environment variable `HMAC_SALT`.
3. the workspace(s) to which you'd like to add the notification configuration.
4. the webhook URL output from Terraform.

Example usage:
```
→ ./files/add_notification_to_workspaces.sh hashidemos andys-lab https://h8alki27g6.execute-api.us-west-2.amazonaws.com/test
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

## References
* [Terraform Cloud Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)
