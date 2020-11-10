# tfc-agent

This repository contains usage examples of the [Terraform Cloud Agent](https://www.terraform.io/docs/cloud/workspaces/agent.html).

The Terraform Cloud Agent is a remote runner for Terraform Cloud that fundamentally gives Terraform Cloud the ability to perform provisioning operations in private networks that are not open to the internet. It does this by establishing an https connection to the Terraform Cloud control plane, and then polling for a terraform provisioning instruction.

When a terraform plan or apply job is available for the agent, it receives a bundle from the control plane that includes the terraform configuration needing to be run. The agent then downloads the terraform binary and executes the plan or apply.

The agent can be run in any environment, typically behind the firewall. This means your terraform code form can reach any system in the network that is reachable from the host where the agent is running. Additionally, the agent itself can pass data to the terraform run environment through the use of environment variables.

Modern networks are microsegmented. In a microsegmented network you can run agents in many different locations, and then based on the terraform workspace select the appropriate agent to be used.

## Contents
* `tfc-agent-ecs` provides an example of running tfc-agent on AWS ECS Fargate, and enabling credential free provisioning using AWS IAM.
* `tfc-agent-vsphere` provides an example of using Packer to build a machine image with tfc-agent runners.
* `tfc-agent-custom` provides an example of customizing the tfc-agent Docker container to fetch secrets and configure the provider.
