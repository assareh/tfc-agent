# Credential free provisioning with Terraform Cloud Agent on GCP GKE

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
      name = "gke"
    }
  }
}
```
Save the file and initialize the remote backend

```
terraform init
```
You are now authenticated into TFCB, the backend is setup allowing you to use the local CLI to communicate with your TFCB workspace.  You can now run teraform output to get your GKE cluster details.

Put the terraform output into a local file we can reference quickly.
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
You should have everythig you need now. Lets Auth to GCP and setup your GKE env.

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