#!/bin/bash
# This Script creates an ADMIN workspace in TFCB if it does not already exist,
# and adds standard terraform & env variables to it using your current host environment.
# This requires Github integration to be setup and a repo to map this admin workspace to.

# WARNING:
# This workspace can manage all sensitive data within your org.
# This should be locked down to owners only and may contain sensitive data in clear text.

# Export ATLAS_TOKEN , Use TFE owners team token for proper access
# Export OAUTH_TOKEN_ID (Github OAuth App Token for VCS integration)
# Export any needed AWS, Azure, GCP access credentials to your shell environment.
#   These will be added to the ADMIN ws and can be used to
#   automatically build future workspaces with encrypted creds.

# Set TFE Address
# Set Organization
# Set Github repo for Admin Workspace vcs
# Set Workspace Name
# Set WORKSPACE_DIR to subfolder to manage multiple organizations

# Usage:
# Optional inputs can be used to override your github repo URL and workspace name.
#
# ./addAdmin_workspace.sh
#

# Provide your TFCB address, TFCB Organization
address="app.terraform.io"
organization="presto-projects"
#  Github Repo URL
git_url="https://github.com/ppresto/tfc-agent.git"
# Admin Workspace Config
workspace="gke_ADMIN_IAM"
# This is the repo dir TFCB will use to run terraform and manage your workspaces with IaC
WORKSPACE_DIR="tfc-agent-gke/gke_ADMIN_IAM"
BRANCH="master"
TF_VERSION="1.0.5"

# set sensitive environment variables/tokens
source $HOME/tfeSetEnv.sh "${organization}"

# Set git_url
if [ ! -z $1 ]; then
  git_url=$1
fi
echo "Using Github repo: $git_url"

# workspace name should not have spaces
if [ ! -z "$2" ]; then
  workspace=$2
fi
echo "Using workspace name: " $workspace

if [ -z ${OAUTH_TOKEN_ID} ]; then
  echo "ERROR:  Set your Github Env variable OAUTH_TOKEN_ID to your oauth token for github integration to work"
  exit 1
fi

if [ -z ${ATLAS_TOKEN} ]; then
  echo "ERROR:  Set your TFE Env variable ATLAS_TOKEN to connect to TFE"
  exit 1
fi


function addKeyVars () {
# Provide 3 Inputs: key_name , key_value, boolean (to enable encryption).
# optional 4th input to manage variable type (terraform/env)
if [[ -z ${4} ]]; then
  category="terraform"
else
  category="env" 
fi

  tee variable.json <<EOF
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"${1}",
      "value":"${2}",
      "category":"${category}",
      "hcl":false,
      "sensitive":${3}
    }
  },
  "filter": {
    "organization": {
      "username":"$organization"
    },
    "workspace": {
      "name":"${workspace}"
    }
  }
}
EOF

}

# You can change sleep duration if desired
sleep_duration=5
save_plan="false"
applied="false"

# Get first argument.
# If not "", Set to git clone URL
# and clone the git repository
# If "", then load code from config directory

# Setup GitHub, Config Dir, and Repo
  config_dir=$(echo $git_url | cut -d "/" -f 5 | cut -d "." -f 1)
  repository=$(echo $git_url | cut -d "/" -f 4,5 | cut -d "." -f 1)

# Make sure $workspace does not have spaces
if [[ "${workspace}" != "${workspace% *}" ]] ; then
    echo "The workspace name cannot contain spaces."
    echo "Please pick a name without spaces and run again."
    exit
fi

# build compressed tar file from configuration directory
#echo "Tarring configuration directory."
#tar -czf ${config_dir}.tar.gz -C ${config_dir} --exclude .git .
# workspace attributes
#Set name of workspace in workspace.json
sed "s/workspace_name/${workspace}/" < workspace.template.json > workspace.json
#Set githib repo for workspace
sed -i.backup "s/org\/workspace_repo/${repository/\//\\/}/g" ./workspace.json
sed -i.backup "s/main/${BRANCH}/g" ./workspace.json

# Allow remote state to be shared globally.  Restrict to specific ws in Prod!
sed -i.backup "s/false/true/g" ./workspace.json

#Set my github org oauth token
sed -i.backup "s/oauth_token_id/${OAUTH_TOKEN_ID}/g" ./workspace.json
sed -i.backup "s/workspace_dir/${WORKSPACE_DIR//\//\\/}/g" ./workspace.json
sed -i.backup "s/VERSION/${TF_VERSION}/g" ./workspace.json

# Check to see if the workspace already exists
echo "Checking to see if workspace exists"
check_workspace_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id

# Create workspace if it does not already exist
if [ -z "$workspace_id" ]; then
  echo "Workspace did not already exist; will create it."
  workspace_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://${address}/api/v2/organizations/${organization}/workspaces")

  echo "Checking Workspace Result: $workspace_result"
  # Parse workspace_id from workspace_result
  workspace_id=$(echo $workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
  echo "Workspace ID: " $workspace_id
else
  echo "Workspace already existed."
fi

# Check if a variables.csv file is in the configuration directory
# If so, use it. Otherwise, use the one in the current directory.
#if [ -f "${config_dir}/variables.csv" ]; then
#  echo "Found variables.csv in ${config_dir}."
#  echo "Will load variables from it."
#  variables_file=${config_dir}/variables.csv
#else
#  echo "Will load variables from ./variables.csv"
#  variables_file=variables.csv
#fi


# Add variables to workspace
#while IFS=',' read -r key value category hcl sensitive
#do
#  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" < variable.template.json  > variable.json
#  echo "Adding variable $key with value $value in category $category with hcl $hcl and sensitive $sensitive"
#  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
#done < ${variables_file}

# Set CONFIRM_DESTROY as a default Environment variable
sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/CONFIRM_DESTROY/" -e "s/my-value/1/" -e "s/my-category/env/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
echo "Adding CONFIRM_DESTROY"
upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")


if [ ! -z ${OAUTH_TOKEN_ID} ]; then
  # OAUTH_TOKEN_ID
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/oauth_token_id/" -e "s/my-value/${OAUTH_TOKEN_ID}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding OAUTH_TOKEN_ID"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
fi

if [ ! -z ${ATLAS_TOKEN} ]; then
  # ATLAS_TOKEN
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/tfe_token/" -e "s/my-value/${ATLAS_TOKEN}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding ATLAS_TOKEN"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
fi

if [ ! -z ${organization} ]; then
  # organization
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/organization/" -e "s/my-value/${organization}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding organization"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
fi

if [ ! -z ${repository} ]; then
  # repository
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/repo_org/" -e "s/my-value/${repository%/*}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding Github org ${repository%/*}"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
fi

# Build GCP Project Credentials
if [[ ! -z ${GOOGLE_CREDENTIALS} && ! -z ${GOOGLE_PROJECT} ]]; then
  # GOOGLE_CREDENTIALS
  gcp_creds="$(echo ${GOOGLE_CREDENTIALS} | jq -c | sed 's/\\n/\\\\n/g' | sed 's/"/\\"/g')"

  addKeyVars "gcp_credentials" "${gcp_creds}" false
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
  # add as ENV var too
  addKeyVars "GOOGLE_CREDENTIALS" "${gcp_creds}" true "env"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")

  # GOOGLE_PROJECT
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/gcp_project/" -e "s/my-value/${GOOGLE_PROJECT}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_PROJECT"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
  # add as ENV var too
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/GOOGLE_PROJECT/" -e "s/my-value/${GOOGLE_PROJECT}/" -e "s/my-category/env/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_PROJECT ENV"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")

fi
# Set Default Region for GCP if Available
if [[ ! -z ${GOOGLE_REGION} && ! -z ${GOOGLE_ZONE} ]]; then
  # GOOGLE_REGION
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/gcp_region/" -e "s/my-value/${GOOGLE_REGION}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_REGION"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
  # add as ENV var too
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/GOOGLE_REGION/" -e "s/my-value/${GOOGLE_REGION}/" -e "s/my-category/env/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_REGION ENV"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")

  # GOOGLE_ZONE
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/gcp_zone/" -e "s/my-value/${GOOGLE_ZONE}/" -e "s/my-category/terraform/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_ZONE"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
  # add as ENV var too
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s/my-key/GOOGLE_ZONE/" -e "s/my-value/${GOOGLE_ZONE}/" -e "s/my-category/env/" -e "s/my-hcl/false/" -e "s/my-sensitive/false/" < variable.template.json  > variable.json
  echo "Adding GOOGLE_ZONE ENV"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
fi

# List Sentinel Policies
sentinel_list_result=$(curl -s --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/policies")
sentinel_policy_count=$(echo $sentinel_list_result | python -c "import sys, json; print(json.load(sys.stdin)['meta']['pagination']['total-count'])")
echo "Number of Sentinel policies: " $sentinel_policy_count


#DEBUG=true
# cleanup
if [[ ! ${DEBUG} ]]; then
  #find ./ -type d -maxdepth 1 -exec rm -rf {} \;
  #find ./ -name "*.tar.gz" -exec rm -rf {} \;
  find ./ -name "*.json.backup" -exec rm -rf {} \;
  rm variable.json workspace.json
fi

echo "Finished"
