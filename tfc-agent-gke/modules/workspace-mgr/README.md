# tfe-workspace Module
Create/Manage your Terraform Enterprise Organizations Workspaces using IaC.
FYI:  Optionally, you can create an "Admin" Workspace as a template to securely populate child workspace's with sensitive variables. This is not required for this tutorial.

## Optional: Create a central Admin Workspace (TFE API)
Create your initial Admin workspace using the TFE API.
Pre-Reqs:
1. Setup Github VCS integration in TFE/TFCB
2. Create github repo for your IaC that will use TFE provider to manage workspaces
3. Read ./create_tfcb_workspaces/TFE_Workspace_README.md
4. Update `./create_tfcb_workspaces`

```
cd ./create_tfcb_workspaces
./addAdmin_workspace.sh
```
This will create your initial TF Admin Workspace with the variables you may need to support TFE/TFC, AWS, Azure.  Update the variables and your environment to ensure you have the proper env variables accessible to this script so it properly builds out your Admin workspace.

Note: GCP is partially covered but you will have to cut/paste the GOOGLE_CREDENTIALS to the variable due to my shell script limitations.

## Create your Sub-Workspaces (TFE Provider)
Create one to many EFT workspaces based on your Admin workspace above.  Update the variables.tf with your workspaces and teams first.  Then

```
cd ..
terraform init
terraform plan
terraform apply
```
