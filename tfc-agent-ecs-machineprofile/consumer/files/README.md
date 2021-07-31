### Change Workspace Execution Mode script

I've also added a helper script to bulk change the workspace [execution mode](https://www.terraform.io/docs/cloud/workspaces/settings.html#execution-mode) to `Agent`.

`./change_ws_exec_mode.sh` will change the workspace execution mode of one or more workspaces in the organization specified. You must provide:
1. a Terraform Cloud organization or admin user token as the environment variable `TOKEN`.
2. your Terraform Cloud organization name.
3. the name of your Agent Pool.
4. the workspace(s) you'd like to change.

Example usage:
```
→ ./change_ws_exec_mode.sh hashidemos my-first-aws-agent-pool my-workspace-1 my-workspace-2
```
