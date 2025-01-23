# HCP Terraform Agent in Amazon ECS Producer Workspace

This workspace will require AWS access/credentials to provision.

## Usage

### Variables
Please provide values for the following required [variables](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables):
* `prefix`: a name prefix to add to the resources
* `tfc_agent_token`: The HCP Terraform Agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in HCP Terraform. (See the next section for how to create this.)

In addition, I recommend that you review all other variables and configure their values according to your specifications. You can adjust the resource allocations for the agent task with `task_cpu`, `task_mem`, `task_def_cpu`, and `task_def_mem`. (Refer to the [AWS docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size) for the supported sizes.) As of this writing, the terraform run environment built in to HCP Terraform provides 2 cores and 2GB of RAM. However, I have used the agent with as little as 256MB of RAM. YMMV

`ttl` and `common_tags` are used only for tagging and are completely optional.

### HCP Terraform Agent Token
An agent token is a secret value that is used to uniquely identify your agents and allow them to register themselves with your HCP Terraform organization. Please refer to the [documentation](https://developer.hashicorp.com/terraform/cloud-docs/agents/agent-pools) for an explanation of what an agent pool is and how to create an agent token in the HCP Terraform Settings console.

Additionally, these may now be created and managed with Terraform due to the addition of the following resources and data sources in version 0.24.0 of the [tfe provider](https://registry.terraform.io/providers/hashicorp/tfe/latest):
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_pool) resource
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/agent_pool) data source
* [`tfe_agent_token`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_token) resource

## Autoscaling tfc-agent with a Lambda Function
I've included a Lambda function that, when combined with [HCP Terraform Run Tasks](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks), enables autoscaling the number of HCP Terraform Agents running. It accomplishes this by booting an agent before each plan/apply, and killing the agent after each run completes.

To use it, you'll need to:
1. Configure the `desired_count` and `max_count` Terraform variables as desired. `desired_count` sets the baseline number of agents to always be running. `max_count` sets the maximum number of agents allowed to be running at one time.

2. Configure the run task in your HCP Terraform organization, and enable it on the desired workspaces. Here's an example usage with the [TFE provider](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs):
```
# This adds the Run Task to the HCP Terraform organization
resource "tfe_organization_run_task" "agent_lambda_webhook" {
  organization = "org-name"
  url          = data.terraform_remote_state.tfc-agent-ecs-producer.outputs.webhook_url
  name         = "tfc-agent"
  enabled      = true
  description  = "tfc-agent"
}

# This enables the Run Task on a particular workspace
resource "tfe_workspace_run_task" "example" {
  workspace_id      = resource.tfe_workspace.example.id
  task_id           = resource.tfe_organization_run_task.agent_lambda_webhook.id
  enforcement_level = "advisory"
  stages            = ["pre_plan", "post_plan", "pre_apply", "post_apply"]
}
```

That's it! When a run is queued, HCP Terraform will send a notification to the Lambda function, increasing the number of running agents. When the run is completed, HCP Terraform will send another notification to the Lambda function, decreasing the number of running agents.

-> **Note:** The [HCP Terraform Operator for Kubernetes](https://github.com/hashicorp/hcp-terraform-operator) can manage and autoscale HCP Terraform Agents. For details please see the [Manage agent pools with the HCP Terraform Operator v2 guide](https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-operator-v2-agentpool).

## References
* [HCP Terraform Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [Agent Pools and Agents API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/agents)
* [Agent Tokens API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/agent-tokens)
* [HCP Terraform Run Tasks Docs](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-tasks)
* [HCP Terraform Run Tasks API Reference](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/run-tasks/run-tasks#run-tasks-api-reference)