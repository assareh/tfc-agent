# tfc-agent-custom

Example showing customization of the default Terraform Cloud Agent image.

The `config-entrypoint.rb` mentioned in the Dockerfile could be used to retrieve secrets and configure the provider environment. For example, retrieving an `.aws` config file for shared profiles to be used by the AWS provider.

## References
* [Terraform Cloud Agents](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent)