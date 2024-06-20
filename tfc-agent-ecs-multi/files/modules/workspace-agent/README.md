# tfe-workspace Module
Create/Manage your Terraform Enterprise Organizations Workspaces using an existing "Admin" Workspace as a template.

## Create your initial Admin Workspace (TFE API)
Create your initial Admin workspace using the TFE API.  Please review the bash script and udpate as needed for your env.

```
cd scripts 
./addAdminWorkspace.sh
```
The addAdminWorkspace.sh that will create your initial TF Admin Workspace with the variables you may need to support TFE/TFC, AWS, Azure.  Update the variables and your environment to ensure you have the proper env variables accessible to this script so it properly builds out your Admin workspace.


Note: GCP is partially covered but you will have to cut/paste the GOOGLE_CREDENTIALS to the variable due to my shell script limitations.

## Create your Sub-Workspaces (TFE Provider)
Create one to many EFT workspaces based on your Admin workspace above.  Update the variables.tf with your workspaces and teams first.  Then 

```
cd ..
terraform init
terraform plan
terraform apply
```
