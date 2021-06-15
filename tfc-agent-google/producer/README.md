# Terraform Cloud Agent in Google Compute Engine Producer Workspace

This workspace will require GCP access/credentials to provision.

## Usage

### Google credentials for Terraform
NOTE: If you already have GCP credentials you may skip steps 1-2.

1. Install gcloud

With Brew:
```
brew install gcloud
```

Or with the installer:
```
curl https://sdk.cloud.google.com |
exec -l $SHELL
gcloud init
```

2. Configure authentication:
```
gcloud auth login
gcloud auth application-default login
```

Q: How to generate credentials for Terraform Cloud?

On a Mac:
```
cat /Users/<your username>/.config/gcloud/application_default_credentials.json | tr -d "\n"
```

Set the output of the above command as the GOOGLE_CREDENTIALS (sensitive) environment variable in your Terraform Cloud workspace.

### Variables
Please provide values for the following required [variables](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables):
* `gcp_project`: your GCP project name
* `tfc_agent_token`: The Terraform Cloud agent token you would like to use. NOTE: This is a secret and should be marked as sensitive in Terraform Cloud. (See the next section for how to create this.)

In addition, I recommend that you review all other variables and configure their values according to your specifications. You can adjust the machine type with `machine_type`. (Refer to the [Google docs](https://cloud.google.com/compute/docs/machine-types) for the supported sizes.) As of this writing, the terraform run environment built in to Terraform Cloud provides 2 cores and 2GB of RAM. However, I have used the agent with as little as 256MB of RAM. YMMV

### Terraform Cloud Agent Token
An agent token is a secret value that is used to uniquely identify your agents and allow them to register themselves with your Terraform Cloud organization. Please refer to the [documentation](https://www.terraform.io/docs/cloud/agents/index.html#managing-agent-pools) for an explanation of what an agent pool is and how to create an agent token in the Terraform Cloud Settings console.

Additionally, these may now be created and managed with Terraform due to the addition of the following resources and data sources in version 0.24.0 of the [tfe provider](https://registry.terraform.io/providers/hashicorp/tfe/latest):
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_pool) resource
* [`tfe_agent_pool`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/agent_pool) data source
* [`tfe_agent_token`](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_token) resource

Prior to the addition of these resources to the tfe provider, I had written helper scripts to create and revoke agent tokens using the Terraform Cloud API. Those scripts remain available [here](../../tfc-agent-ecs/producer/files/README.md).
