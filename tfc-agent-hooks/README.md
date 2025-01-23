# tfc-agent-hooks

An example showing customization of the default HCP Terraform Agent image to include custom programs at strategic points of the Terraform runs. 

In this scenario, there are pre-plan, post-plan, pre-apply, and post-apply scripts that will execute at those points of each run. The sample pre-plan and pre-apply hooks shown here will authenticate to HashiCorp Vault and retrieve unique short-lived credentials for AWS provisioning. The post-plan and post-apply hooks will revoke those credentials. For more details on this usage pattern please see [AWS Dynamic Credentials for HCP Terraform with Vault and Workload Identity](https://github.com/assareh/workload-identity-vault/).

## References
* [HCP Terraform Agent Hooks](https://developer.hashicorp.com/terraform/cloud-docs/agents/hooks)
* [tfc-agent Docker Hub](https://hub.docker.com/r/hashicorp/tfc-agent)