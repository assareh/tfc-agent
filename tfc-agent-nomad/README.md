# tfc-agent-nomad

Example job files for running tfc-agent on Nomad. In these examples I am retrieving the TFC_AGENT_TOKEN from HashiCorp Vault.

`tfc-agent.nomad` is an example using the [docker driver](https://www.nomadproject.io/docs/drivers/docker).
`tfc-agent-exec.nomad` is an example using the [exec driver](https://www.nomadproject.io/docs/drivers/exec).

## References
* [HCP Terraform Agent Docs](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [Nomad Job Specification Docs](https://developer.hashicorp.com/nomad/docs/job-specification)
* [tfc-agent Releases](https://releases.hashicorp.com/tfc-agent/)
* [tfc-agent Docker Hub](https://hub.docker.com/r/hashicorp/tfc-agent)