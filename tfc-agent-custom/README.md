# tfc-agent-custom

An example showing customization of the default HCP Terraform Agent image to include other software packages.

In this scenario, the `config-entrypoint.rb` mentioned in the Dockerfile was used to access AWS Secrets Manager, retrieve an [aws config file](https://docs.aws.amazon.com/credref/latest/refdocs/creds-config-files.html) for AWS provider shared profiles, and place it on the file system, making it available to be used by the terraform workspaces using this agent.

## References
* [HCP Terraform Agent Docs](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [tfc-agent Docker Hub](https://hub.docker.com/r/hashicorp/tfc-agent)