# Credential free provisioning with Terraform Cloud Agent on GCP GKE
This Demo will create the TFCB and GCP resources needed to enable multiple teams to each use IaC in their own isolated environments that require no GCP credentials.  Each team will have a K8s namespace, and a mapping between their K8s service account and Google service account (GSA).  The GSA contains the specific roles the IAM team want to provide each team access to.  Using Google Workload Identity the K8s SA is linked to the GSA.  So the tfc-agent running as a K8s SA will be limitted by the GSA Roles its linked to.  These roles will apply to all Kubernetes clusters within a GCP project unless conditions are defined.

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

## Create Core IAM resources and TFCB workspaces
Click `gke_ADMIN_IAM` -> Actions -> Start new plan -> Start Plan

This will run the IaC in ./gke_ADMIN_IAM and create the access and resources needed by all teams defined in var.iam_teams{} (`./gke_ADMIN_IAM/variables.tf`).  This will create the 2 default team workspaces with no credentials and configure them to each use the correct TFCB agentpool. Additionally it will create workspaces for the core servicess gke_cluster and gke_svc_tfcagents that we will run next.

**Currently var.iam_teams assumes every team will have its own unique K8s namespace and service account that doesn't currently exist. The gke_cluster workspace will read these values and attempt to create them.**

## Provision GKE
Click `gke_cluster` -> Actions -> Start new plan -> Start Plan

This will run the IaC in ./gke_cluster to create your VPC, GKE cluster, and each of the defined Team's kubernetes namespace and service account.  Once complete you should have a fully useable GKE cluster with the necessary namespaces created for the teams that will consume it.  We will deploy the tfc-agents into these namespaces next.  But first take a look at the GKE cluster.

### Authenticate to GKE on the command line
You can get the information from the gke workspace outputs in GCP or TFCB UI.  Alternatively you can use the Terraform CLI!  If you want to use your CLI, first login.
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
You are now authenticated into TFCB, the backend is setup allowing you to use the local CLI to communicate with your TFCB workspace.  You can now run teraform output to get your GKE cluster details locally which the `./gke_cluster/setkubectl.sh` will attempt to do for you.

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
You should have everythig you need now. Run the script: `./setkubectl.sh`.
```
./setkubectl.sh
```
You can also do this manually with the commands below assuming you set these variables in your environment when you did the tf output test above.

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
Every team defined will have a tfc-agent service deployed within their K8s namespace.  This service will use the defined K8s SA which is mapped to the team's Google SA.  Roles to the allowed API's are defined at the Google SA level and this was all created in `gke_ADMIN_IAM`.

Click `gke_svc_tfcagents` -> Actions -> Start new plan -> Start Plan

This will run the IaC in ./gke_svc_tfcagents that will apply a K8s tfc-agent deployment in the teams K8s namespace.  You should take a close look at each `tfc-team#` namespace in your K8s cluster.
```
kubectl get namespaces
NAME              STATUS   AGE
default           Active   97m
kube-node-lease   Active   97m
kube-public       Active   97m
kube-system       Active   98m
tfc-team1         Active   94m
tfc-team2         Active   94m
```

To look at the resources built for team1 do the following:
```
kubectl config set-context --current --namespace=tfc-team1
kubectl get pods
kubectl get deployment
kubectl get secret
kubectl get sa
```

If you take a close look at the service account (sa) you will see an annotation mapping it to the team's Google service account + project which has the roles that enable which API's the tfc-agent will have access to.
```
kubectl get sa tfc-team1-dev -o json | jq -r '.metadata.annotations'
```
If you want to change a teams access permissions you will need to first update the team's roles in var.iam_teams defined in `./gke_ADMIN_IAM/variables.tf`.  This will trigger an automatic run and the team's GSA will be updated.  The current running tfc-agent service should pick these up the next run automatically.

## Run Team1 and Team2 workspaces
Now you have two team workspaces that are eached mapped to a different repo/workingdir.  Any IaC updates will trigger a run within the given workspace.  Each are mapped to a different agentpool that has a different tfc-agent listening.  The tfc-agent will provision the IaC using the Google Service Account associated to each teams kubernetes service account and namespace hosting the tfc-agent.  If you look at the workspace variables you should find no sensitive cloud credentials in these workspaces.

Testing...
* Run a plan in gke_tfc_team1 and it should successfully build a compute instance.
* Run a plan in gke_tfc_team2 and it should fail.

Team2 is configured the same and using the same tf code as team1.  The only difference is the google service account built for team2 was only assigned storage.Admin role so it doesn't have access to build compute.  You can update the roles for each team in `./gke_ADMIN_IAM/variables.tf`

## Notes/Troubleshooting

### Nested Variables
To support multiple teams sometimes more complex structures are needed.  This demo uses local variables to dynamically generate the right values at runtime and pulls some of these values from nested maps.  To troubleshoot looping through complex objects use local variables and outputs found here: `./test/test_nested_opjects.tf`.

```
cd ./test
terraform init
terraform plan
```
### GCP Service Accounts
Setting up GCP service account with IAM roles and then map this to K8s namespace/serviceaccount.  This will apply to any K8s cluster in the project unless additional IAM conditions are added to isolate clusters.

list/delete gsa
```
gcloud iam service-accounts list
gcloud iam service-accounts delete <email>
```

Test default K8s cluster service account (use test with storage permission).
```
kubectl run --rm -it test --image gcr.io/cloud-builders/gsutil ls
```

Test tfc-agent namespace/sa with storage permission
```
kubectl run -n tfc-agent --rm --serviceaccount=servicea-dev-deploy-servicea -it test --image gcr.io/cloud-builders/gsutil ls
```

### HCP Vault GKE Integration
Refer to `./gke_cluster/main.tf.withVault` for an example of installing the vault injector.  This allows us to update the tfc-agent deployment by only adding some pod annotations.  The devwebapp use case below is based on the [Vault learn guide](https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault?in=vault/kubernetes).  Walk though this on your vaul cluster to setup any auth/secrets/policies on the vault side.

Test authentiation by starting the basic devwebapp pod that has the VAULT_TOKEN defined.  be sure to update the devwebapp.yaml to point to your vault instance, token, and namespace.
```
cd ./test
kubectl apply -f devwebapp.yaml
kubectl exec --stdin=true --tty=true devwebapp_podname -- /bin/sh
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl --insecure --request POST \
      -H "X-Vault-Namespace: admin" \
      --data '{"jwt": "'"$KUBE_TOKEN"'", "role": "devweb-app"}' \
      $VAULT_ADDR/v1/auth/kubernetes/login
```

Setup the tfc-agent deployment to use vault annotations by defining the following variable for ./modules/gke-tfcagent
```
deployment_annotations = {
    "vault.hashicorp.com/agent-inject" = "true"
    "vault.hashicorp.com/namespace" = "admin/"
    "vault.hashicorp.com/role" = "devweb-app"
    "vault.hashicorp.com/tls-skip-verify": "true"
    "vault.hashicorp.com/log-level" = "debug"
    "vault.hashicorp.com/agent-inject-secret-credentials.txt" = "secret/data/devwebapp/config"
  }
```

Use the devwebappp-agentinjector.yaml to test the tfc-agent pod using the vault annotations.
vault-agent-init (only has wget)
```
kubectl apply -f devwebappp-agentinjector.yaml
kubectl exec -it <podname> sh
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
export VAULT_ADDR="https://hcp-vault-cluster.vault.11eb13d3-0dd1-af4a-9eb3-0242ac110018.aws.hashicorp.cloud:8200"

wget -O - -q --no-check-certificate --header="X-Vault-Namespace: admin" \
--post-data '{"jwt": "'"$KUBE_TOKEN"'", "role": "devweb-app"}' \
$VAULT_ADDR/v1/auth/kubernetes/login
```

## Additional Topics
* A [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) policy like [this example](https://github.com/hashicorp/terraform-guides/blob/master/governance/third-generation/aws/restrict-assumed-roles-by-workspace.sentinel) can be used to restrict which roles would be allowed in a given workspace.
* Terraform code and policies to support IAM roles and workspaces for example service-A and service-B are in `/files`.

## References
* [Bind Google SA to Kubernetes SA to enforce IAM roles](https://medium.com/the-telegraph-engineering/binding-gcp-accounts-to-gke-service-accounts-with-terraform-dfca4e81d2a0)
* [Google Workload Identity IAM conditions](https://medium.com/google-cloud/solving-the-workload-identity-sameness-with-iam-conditions-c02eba2b0c13)
* [Terraform Cloud Agent Docs](https://www.terraform.io/docs/cloud/workspaces/agent.html)
* [Agent Pools and Agents API](https://www.terraform.io/docs/cloud/api/agents.html)
* [Agent Tokens API](https://www.terraform.io/docs/cloud/api/agent-tokens.html)