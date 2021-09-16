# Credential free provisioning with Terraform Cloud Agent on GCP GKE

## Create the IAM Admin workspace using TFCB API
This workspace will create the following Identify and resource requirements for every team.
* Google service account, Roles, and Workload Identity Mapping
* Kubernetes service account (placeholder)
* Kubernetes namespace (placeholder)
* TFCB Agent Pool and Token per team
* Default TFCB Team Workspace to build IaC

1. First fork this repo in your github.com account and clone it locally.
```
cd <your_working_project_dir>  # this is your project base dir. It can by any dir you want.
git clone <your_git_URL>
cd tfc-agents/tfc-agent-gke/scripts
```

2. `./addAdmin_workspace.sh` uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs are often used from Jenkins or other solutions to incorporate Terraform Enterprise into a CI/CD pipeline.

This script requires the default TFE and GCP variables to be locally sourced into your shell during runtime. It will build the new workspace with these defined. Sensitive credentials like ATLAS_TOKEN and GOOGLE_CREDENTIALS will be encrypted for security.

Required environment variables in your shell.
```
OAUTH_TOKEN_ID <setup github oauth and use ID here>
ATLAS_TOKEN <Enterprise TF Token>
organization <your github org name>
GOOGLE_CREDENTIAL
GOOGLE_PROJECT
GOOGLE_REGION
GOOGLE_ZONE
```

Once these are available in your shell's env you are ready to build the admin workspace.
```
$  ./addAdmin_workspace.sh
Using Github repo: https://github.com/ppresto/tfc-agent.git
Using workspace name:  gke_ADMIN_IAM
Checking to see if workspace exists
Traceback (most recent call last):
  File "<string>", line 1, in <module>
KeyError: 'data'
Workspace ID:
Workspace did not already exist; will create it.
Checking Workspace Result: {"data":{"id":"ws-JBHmrQUaM7cfYADr","type":"workspaces","attributes":{"allow-destroy-plan":true,"auto-apply":true,"auto-destroy-at":null,

...

Workspace ID:  ws-JBHmrQUaM7cfYADr
Adding CONFIRM_DESTROY
Adding OAUTH_TOKEN_ID
Adding ATLAS_TOKEN
Adding organization
Adding Github org ppresto

...

Adding GOOGLE_PROJECT
Adding GOOGLE_PROJECT ENV
Adding GOOGLE_REGION
Adding GOOGLE_REGION ENV
Adding GOOGLE_ZONE
Adding GOOGLE_ZONE ENV
Number of Sentinel policies:  0
Finished
```
Login to TFCB and you should see the admin workspace you just created (default: `gke_ADMIN_IAM`).  Under variables you should see all your Terraform and ENV variables properly set to build out your core GCP Platform.

3.  Click this workspace -> Actions -> Start new plan

This will run the IaC in ./gke_ADMIN_IAM and create the access and resources needed by all teams defined in iam_teams{} (./gke_ADMIN_IAM/variables.tf).  Additionally it will create workspaces gke_cluster and  gke_svc_tfcagents service we will deploy next.

## Provision GKE

### Authenticate to GKE on the command line

1. (Optional) You can get the information from the gke workspace outputs in TFCB.  If you want to use your CLI, first login.
```
terraform login
```
This will request an API token using your browser and store it in `$HOME/.terraform.d/credentials.tfrc.json`.  This will be used by terraform to communicate to the TFCB backend.

Update the `./tfc-agent-gke/gke/backend.tf` to point to your TFCB Organization
```
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "<ADD_YOUR_ORG_HERE>"

    workspaces {
      name = "gke_cluster"
    }
  }
}
```
Save the file and initialize the remote backend

```
terraform init
```
You are now authenticated into TFCB, the backend is setup allowing you to use the local CLI to communicate with your TFCB workspace.  You can now run teraform output to get your GKE cluster details locally which the `./gke/setkubectl.sh` will attempt to do for you.

Test the terraform output is working and setting all the necessary variables correctly.
```
terraform output -json > ./tf.out

gcp_region=$(jq -r '.region.value' ./tf.out)
gcp_zone=$(jq -r '.zone.value' ./tf.out)
gcp_project=$(jq -r '.gcp_project.value' ./tf.out)
gcp_cluster_name=$(jq -r '.kubernetes_cluster_name.value' ./tf.out)
gcp_gke_context=$(jq -r '.context.value' ./tf.out)

echo $gcp_region
echo $gcp_zone
echo $gcp_project
echo $gcp_cluster_name
echo $gcp_gke_context
```
You should have everythig you need now. Run the script: `./setkubectl.sh` or do it manually with the commands below assuming you set these variables in your environment with the test above.

```
echo ${GOOGLE_CREDENTIALS} > /tmp/credential_key.json
gcloud auth activate-service-account --key-file=/tmp/credential_key.json
gcloud config set project ${gcp_project}
gcloud config set compute/region ${gcp_region}
gcloud container clusters get-credentials ${gcp_cluster_name} --region ${gcp_zone}
rm /tmp/credential_key.json
rm tf.out
```

## Provision tfc-agents as a GKE service

Set the current context namespace for simpicity
```
kubectl config set-context --current --namespace=tfc-agent
```

## Notes

### Vault GKE Integration
Test authentiation by starting the basic devwebapp pod and connecting to it.
```
cd gke
kubectl apply -f devwebapp.yaml
kubectl exec --stdin=true --tty=true devwebapp -- /bin/sh
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl --insecure --request POST \
      -H "X-Vault-Namespace: admin" \
      --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "devweb-app"}' \
      $VAULT_ADDR/v1/auth/kubernetes/login

```

vault-agent-init (only has wget)
```
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
export VAULT_ADDR="https://hcp-vault-cluster.vault.11eb13d3-0dd1-af4a-9eb3-0242ac110018.aws.hashicorp.cloud:8200"

wget -O - -q --no-check-certificate --header="X-Vault-Namespace: admin" \
--post-data '{"jwt": "'"$KUBE_TOKEN"'", "role": "devweb-app"}' \
$VAULT_ADDR/v1/auth/kubernetes/login
```

### GCP Service Accounts
Setting up GCP service account with IAM roles and then map this to K8s namespace/serviceaccount.  This will apply to any K8s cluster in the project unless additional IAM conditions are added to isolate clusters.


Test default K8s cluster service account (use test with storage permission)
```
kubectl run --rm -it test --image gcr.io/cloud-builders/gsutil ls
```

Test tfc-agent namespace/sa with storage permission
```
kubectl run -n tfc-agent --rm --serviceaccount=servicea-dev-deploy-servicea -it test --image gcr.io/cloud-builders/gsutil ls
```

IAM Ref: https://medium.com/the-telegraph-engineering/binding-gcp-accounts-to-gke-service-accounts-with-terraform-dfca4e81d2a0

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.


## References
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)