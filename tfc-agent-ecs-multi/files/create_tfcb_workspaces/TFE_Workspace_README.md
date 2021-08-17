# TFE Automation Script
`./scripts/addAdmin_workspace.sh` creates a workspace that is integrated with a GitHub repo.  This script can create your initial ADMIN Workspace which can hold sensitive terraform/env variables and should be locked down to owners only.  This workspace can then be used to securely create child workspaces configured with your sensitive credentials already encrypted.

## Introduction
This script uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs could be used from Jenkins or other solutions to incorporate Terraform Enterprise into your CI/CD pipeline.

You can Add your sensitive Cloud credentials by sourcing them into your shell as local environment variables.  The default script will look for the default AWS, GCP, or Azure ENV variables during runtime. Here are a list of terraform and environment variables the script will look for.


Required
```
OAUTH_TOKEN_ID <setup github oauth and use ID here>
ATLAS_TOKEN <Enterprise TF Token>
organization <your github org name>
```

Recommended for this AWS excersize.
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

Other
```
ARM_CLIENT_ID
ARM_SUBSCRIPTION_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
GOOGLE_CREDENTIAL
GOOGLE_PROJECT
GOOGLE_REGION
GOOGLE_ZONE
```

You will see a couple `template.json` files in this ./scripts directory.  The script will update these templates and using curl will call the TFCB API to create your workspace and any defined variables.
* You can uncomment the DEBUG variable at the bottom of the script if you want to review the files that get created and used in the API calls for troubleshooting.

## Setup
1. Sign up for a TFC account, login, and create your organization
2. [Setup VCS integration](https://www.terraform.io/docs/cloud/vcs/github.html) with your Github account/org
3. Generate a [team token](https://www.terraform.io/docs/enterprise/users-teams-organizations/service-accounts.html#team-service-accounts) for the owners team in your organization.  In the Terraform Enterprise UI select your organization settings, then Teams, then owners, and then click the Generate button and save the token that is displayed.  Set the env variable ATLAS_TOKEN=<team token>.
4. Make sure [python](https://www.python.org/downloads/) is installed on your machine and in your path since the script uses python to parse JSON documents returned by the Terraform Enterprise REST API.  You can updated the script to use jq if you want.
5. Build your first workspace using the API script in this repo.

To use the TFCB API script you need to update it for your environment.  
```
cd ./scripts
```

Customize the following variables in `./addAdmin_workspace.sh`:
```
# The default is using the TFCB address. Update if using TFE onprem.
address="app.terraform.io"

# Update the organization with your TFCB organization name
organization="presto-projects"

# Set this github URL to your forked version of this repo
git_url="https://github.com/ppresto/tfc-agent.git"

# Admin Workspace Name
workspace="ADMIN-TFCB-WS"

# Github repo path to use for managing your workspaces with IaC
WORKSPACE_DIR="tfc-agent-ecs-multi/files/create_tfcb_workspaces"
BRANCH="main"

# Select Terraform Version
TF_VERSION="0.13.6"

```

6. Pre-Check
Verify you have the 3 Required environment variables set (OAUTH_TOKEN_ID, ATLAS_TOKEN, organization)
```
env
```
There are many different ways to manage credentials in your TFC workspace. One option can be to use this Admin workspace.  Source your Cloud credentials into your shell env to securely copy them over HTTPS into your admin workspace.  When building child workspaces you can now reference these variables from the admin workspace and have them populated into the child workspace as write only variables.  This design allows only the Admin to see the secrets while all child workspaces inherit them for provisioning access.

1. Run the script
```
./addAdmin_workspace.sh
```
You should now have your ADMIN workspace created in TFCB and be ready to provision child workspaces with standard configurations and securely add encrypted sensitive variables too.

### Note: Using with Private Terraform Enterprise Server using private CA
If you use this script with a Private Terraform Enterprise (PTFE) server that uses a private CA instead of a public CA, you will need to ensure that the curl commands run by the script will trust the private CA.  There are several ways to do this.  The first is easiest for enabling the automation script to run, but it only affects curl. The second and third are useful for using the Terraform and TFE CLIs against your PTFE server. The third is a permanent solution.
1. `export  CURL_CA_BUNDLE=<path_to_ca_bundle>`
1. Export the Golang SSL_CERT_FILE and/or SSL_CERT_DIR environment variables. For instance, you could set the first of these to the same CA bundle used in option 1.
1. Copy your certificate bundle to /etc/pki/ca-trust/source/anchors and then run `update-ca-trust extract`.