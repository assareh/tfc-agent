# Credential free provisioning with HCP Terraform Agent on Google Cloud Platform

This repository provides an example of running [tfc-agent](https://hub.docker.com/r/hashicorp/tfc-agent) on Google Compute Engine, and shows how you can leverage tfc-agent to perform credential free provisioning using [service account impersonation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#impersonating-service-accounts). Though this simple example shows usage within a single project, this pattern is used to allow provisioning across projects without requiring GCP credentials in Terraform workspaces.

## Setup
The `producer` workspace contains an example of registering and running the tfc-agent on a compute instance, along with the necessary IAM permission and role bindings.

The `consumer` workspace provides an example of provisioning an instance without placing credentials in the HCP Terraform workspace.

## Steps
1. Configure and provision the `producer` workspace. See [README](./producer/README.md) for instructions.
2. Configure and provision the `consumer` workspace, using the `terraform-dev-role` created in step 1. See [README](./consumer/README.md) for instructions.

## Notes
* Please ensure the consumer workspace [Execution Mode](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode) is set to Agent!

## Additional Topics
* Service Account Impersonation is not required. IAM permissions given to the instance service account directly will be available to Terraform runs without any provider configuration necessary. ([Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#running-terraform-on-google-cloud))
* A [Sentinel](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/define-policies/custom-sentinel) policy like [this example](https://github.com/hashicorp/terraform-sentinel-policies/blob/main/aws/restrict-assumed-roles-by-workspace.sentinel) can be translated to GCP to restrict which roles would be allowed to be impersonated in a given workspace.
* The tfc-agent is a good fit for GKE.

## Other approaches to running tfc-agent on GCP that I attempted
Serverless sounds quite appealing, however there were challenges.
* **Cloud Run**: FAILED. First I found there are [reports of issues](https://stackoverflow.com/questions/61744540/unable-to-deploy-ubuntu-20-04-docker-container-on-google-cloud-run) running Ubuntu 20.04 on Cloud Run, and the official container from HashiCorp is based on Ubuntu 20.04. I built my own container on 18.04. Next is per the [Cloud Run Container runtime contract](https://cloud.google.com/run/docs/reference/container-contract#port), the container must have a listener. Well obviously since the tfc-agent makes outbound connections only, it does not have a listener. So I solved that by adding a dummy NGINX proxy as a listener. With these I was able to make it run, but it would fail to register itself with HCP Terraform and die. That ultimately led me to [this](https://stackoverflow.com/questions/57257903/google-cloud-run-and-golang-goroutines) post by AhmetB at Google explaining that applications starting goroutines in the background are not suitable for Cloud Run because when there are no inbound requests they are throttled to zero CPU.
* **App Engine**: FAILED. Similar reasons as above.

## References
* [HCP Terraform Agent Docs](https://developer.hashicorp.com/terraform/cloud-docs/agents)
* [Agent Pools and Agents API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/agents)
* [Agent Tokens API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/agent-tokens)
* [Google Provider Authentication Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#running-terraform-on-google-cloud)
* [A Hitchhiker’s Guide to GCP Service Account Impersonation in Terraform](https://medium.com/google-cloud/a-hitchhikers-guide-to-gcp-service-account-impersonation-in-terraform-af98853ebd37)
* [Terraform “Assume Role” and service Account impersonation on Google Cloud](https://medium.com/google-cloud/terraform-assume-role-and-service-account-impersonation-on-google-cloud-ffc553863e72)
