# HCP Terraform Agent Examples

This repository contains usage examples of the [HCP Terraform Agent](https://developer.hashicorp.com/terraform/cloud-docs/agents). HCP Terraform Agents allow HCP Terraform to communicate with isolated, private, or on-premises infrastructure. HCP Terraform Agent is also supported by Terraform Enterprise.

-> **Note:** tfc-agent refers to HCP Terraform Agent.

-> **Note:** While the examples provided here of leveraging cloud provider IAM to issue dynamic credentials for agent-based HCP Terraform runs are still valid, the [Dynamic provider credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials) feature set is now the recommended approach in most cases.

* `tfc-agent-ecs` provides an example of running tfc-agent on AWS ECS Fargate, and enabling credential free provisioning from HCP Terraform by leveraging AWS IAM and [AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) to automatically generate short-lived security credentials.
* `tfc-agent-hooks` provides an example of a custom tfc-agent container leveraging [Hooks](https://developer.hashicorp.com/terraform/cloud-docs/agents/hooks) to deliver just in time short-lived AWS credentials from Vault. 
* `tfc-agent-azure` provides an example of running tfc-agent on Azure Container Instances, and enabling credential free provisioning from HCP Terraform by leveraging Azure MSI to automatically generate short-lived security credentials. (Beta)
* `tfc-agent-google` provides an example of running tfc-agent on Google Compute Engine, and enabling credential free provisioning from HCP Terraform by leveraging GCP IAM and [Service Account Impersonation](https://cloud.google.com/iam/docs/impersonating-service-accounts) to automatically generate short-lived security credentials.
* `tfc-agent-vsphere` provides an example of using Packer to build a machine image with tfc-agent runners.
* `tfc-agent-custom` provides an example of customizing the tfc-agent Docker container to fetch secrets and configure a provider.
* `tfc-agent-nomad` provides example job files that can be used to run tfc-agent on a Nomad cluster.

## Overview
The HCP Terraform Agent is a remote runner for HCP Terraform that gives the ability to provision resources in private networks that are not open to the internet. It does this by establishing an HTTPS connection to the HCP Terraform control plane, and then polling for instructions.

When a terraform plan or apply job is available for the agent, it receives a bundle from the control plane that includes the terraform configuration needing to be run. The agent then downloads the terraform version specified in the workspace, executes the plan or apply, and transmits the results back to the control plane.

The agent can be run in any environment, and typically behind the firewall. This means your terraform code can reach any system in the network that is reachable from the host where the agent is running. Additionally, the agent itself can pass data to the terraform run environment through the use of environment variables.

## Other Resources
* [HCP Terraform Agent Docs](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [HCP Terraform Agent on TFE Docs](https://developer.hashicorp.com/terraform/enterprise/application-administration/agents-on-tfe)
* [HCP Terraform Operator Guide](https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-operator-v2-agentpool)
* [hashicorp/tfc-agent on DockerHub](https://hub.docker.com/r/hashicorp/tfc-agent)
* [terraform-cloud-agent on Kubernetes module by Phil Sautter](https://registry.terraform.io/modules/redeux/terraform-cloud-agent/kubernetes/latest)
* [tfc-cloud-agent on Kubernetes module by Cloud Posse](https://registry.terraform.io/modules/cloudposse/tfc-cloud-agent/kubernetes/latest)
* [tfc_agent Chef cookbook](https://supermarket.chef.io/cookbooks/tfc_agent)
