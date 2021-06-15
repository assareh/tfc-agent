# tfc-agent

This repository contains usage examples of the [Terraform Cloud Agent](https://www.terraform.io/docs/cloud/workspaces/agent.html).

* `tfc-agent-ecs` provides an example of running tfc-agent on AWS ECS Fargate, and enabling credential free provisioning from Terraform Cloud by leveraging AWS IAM and [AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html) to automatically generate short-lived security credentials.
* `tfc-agent-google` provides an example of running tfc-agent on Google Compute Engine, and enabling credential free provisioning from Terraform Cloud by leveraging GCP IAM and [Service Account Impersonation](https://cloud.google.com/iam/docs/impersonating-service-accounts) to automatically generate short-lived security credentials.
* `tfc-agent-vsphere` provides an example of using Packer to build a machine image with tfc-agent runners.
* `tfc-agent-custom` provides an example of customizing the tfc-agent Docker container to fetch secrets and configure a provider.
* `tfc-agent-nomad` provides example job files that can be used to run tfc-agent on a Nomad cluster.

## Overview
The Terraform Cloud Agent is a remote runner for Terraform Cloud that gives the ability to provision resources in private networks that are not open to the internet. It does this by establishing an HTTPS connection to the Terraform Cloud control plane, and then polling for instructions.

When a terraform plan or apply job is available for the agent, it receives a bundle from the control plane that includes the terraform configuration needing to be run. The agent then downloads the terraform version specified in the workspace, executes the plan or apply, and transmits the results back to the control plane.

The agent can be run in any environment, and typically behind the firewall. This means your terraform code can reach any system in the network that is reachable from the host where the agent is running. Additionally, the agent itself can pass data to the terraform run environment through the use of environment variables.

## Other Resources
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [hashicorp/tfc-agent on DockerHub](https://hub.docker.com/r/hashicorp/tfc-agent)
* [terraform-cloud-agent on Kubernetes module by Phil Sautter](https://registry.terraform.io/modules/redeux/terraform-cloud-agent/kubernetes/latest)
* [tfc-cloud-agent on Kubernetes module by Cloud Posse](https://registry.terraform.io/modules/cloudposse/tfc-cloud-agent/kubernetes/latest)
* [tfc_agent Chef cookbook](https://supermarket.chef.io/cookbooks/tfc_agent)
