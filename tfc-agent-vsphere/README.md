# tfc-agent-vsphere

A simple Packer template to run tfc-agent on a vSphere virtual machine. I created this for demos and should be properly hardened for usage outside of a lab environment.

## Steps
Tested with Packer 1.6.5.
1. Set/edit/customize the variable values in the Packer template per your configuration as needed.
2. Create an [agent token](https://developer.hashicorp.com/terraform/cloud-docs/agents) and set it as the `TFC_AGENT_TOKEN` environment variable. (Alternatively this could be sourced from HashiCorp Vault).
3. Export your vCenter Server password as the `VCENTER_PASSWORD` environment variable. On some operating systems you can copy the password to your clipboard and use pbpaste like so:
```
export VCENTER_PASSWORD=`pbpaste`
```
4. Run `packer build tfc-agent-vsphere.json`
5. After the Packer build has completed you'll need to power on the virtual machine in vCenter.

## Notes
* Notice that it is possible to pass environment variables from the agent to the Terraform run environment. Depending on the scenario this may not be appropriate for secrets, but can be used for other values. Also see `tfc-agent-custom` in this repo for more advanced techniques around providing secrets to the tfc-agent Terraform run environment.

## References
* [HCP Terraform Agent Docs](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [Packer vsphere-iso Builder Docs](https://developer.hashicorp.com/packer/integrations/hashicorp/vsphere/latest/components/builder/vsphere-iso)
* [tfc-agent Releases](https://releases.hashicorp.com/tfc-agent/)
* [tfc-agent Docker Hub](https://hub.docker.com/r/hashicorp/tfc-agent)