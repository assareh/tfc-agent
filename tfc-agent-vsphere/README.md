# tfc-agent-vsphere
simple packer example to run tfc-agent on a vsphere vm

## Steps
Tested with Packer 1.6.5.
1. Create an [agent token](https://www.terraform.io/docs/cloud/workspaces/agent.html) and set it as the `TFC_AGENT_TOKEN` environment variable.
2. Export your vCenter Server password as the `VCENTER_PASSWORD` environment variable. On some operating systems you can copy the password to your clipboard and use pbpaste like so:
```
export VCENTER_PASSWORD=`pbpaste`
```
3. Set or modify values or variables in the Packer template pe your configuration as needed.
4. Run `packer build tfc-agent-vsphere.json`
5. Once the image has been created, you'll need to power it on.

## Notes
* We are providing vSphere provider arguments like `vsphere_server`, `user`, and `password` to the tfc-agent directly, eliminating the need for consumers to set these values in their Terraform Cloud workspaces.