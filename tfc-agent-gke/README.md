# Credential free provisioning with Terraform Cloud Agent on GCP GKE

## Provision GKE

## Provision tfc-agents as a GKE service

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