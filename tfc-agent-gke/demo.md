# GKE Demo
Using the TFCB API you will create the main admin workspace responsible for managing TFCB and GCP IAM.  Run this workspace to create IAM resources for team1 and team2, and additional GKE and team workspaces needed for the demo.  There are many ways to manage cloud credentials for TFCB agents!!  In this demo you will create a TFCB agent pool for each business unit or team to fully isolate their provisioning processes.  Instead of managing credentials for each team you will leverage Google Workload Identity which will allow you to create a Google Service account, define allowed roles for it, and the TFCB agent will assume these roles during provisioning.  In other words, Business units or teams don't need to have cloud credentials, and you wont be storing any sensitive data in TFCB.  WooHoo!!


## Create Admin workspace to bootstrap environment
define the TFE ATLAS_TOKEN, and default GCP variables including GOOGLE_CREDENTIALS into your local environment.  These are required to build the admin workspace `gke_ADMIN_IAM` that will bootstrap your TFCB environment.

`Open TFCB Browser to your TFCB Organization` : presto-projects

```
cd ./scripts
source $HOME/tfeSetEnv.sh presto-projects
source $HOME/gcpSetEnv.sh
./addAdmin_workspace.sh
```
**tfeSetEnv.sh, gcpSetEnv.sh are placeholders and not part of this repo**

To manually set up the required environment variables refer to `./scripts/TFE_Workspace_README.md`

### Review gke_ADMIN_IAM
Run the gek_ADMIN_IAM workspace to create all resources while reviewing the IaC below.
```
gke_ADMIN_IAM -> Actions -> Start new plan -> Start plan
```

**This workspace manages identity and access for every business unit or team.**
* It creates the GSA with roles we define in variables.tf
* It defines placeholders for the GKE namespace and SA the business unti will leverage in their GKE cluster.

`Open VCode tab ./gke_ADMIN_IAM/variables.tf ` : local.iam_teams
  * Google SA and Roles
  * GKE Namespace
  * GKE SA
  * Team Workspace Ex

Every team defined will call this IAM bootstrap module

`Open VCode tab ./modules/iam-team-setup/main.tf`
* It creates a TFCB workspace and an Agent Pool that will manage all the team's provisioning
* Show GSA, Roles, and Workload Idenity mapping to GKE (namespace/sa)

### Review gke_cluster
**Building this cluster takes >15min so pre-build the demo in another org if presenting and switch to that now**
```
gke_cluster -> Actions -> Start new plan -> Start plan
```

This workspace might be owned by the platform team managing the GKE cluster.  It creates our GKE cluster with the latest namespaces and service accounts defined in `local.iam_teams`.

`Open VCode tab ./gke_cluster/main.tf`

This workspace is using remote_state to pull the latest team configurations from the IAM workspace to configure GKE namespaces and service accounts.SA

`Open TFCB Browser Tab to gke_ADMIN_IAM outputs` : team_iam_config

`Switch back to the VCode tab ./gke_cluster/main.tf`
* At the bottom of main.tf the GKE SA is being configured with an annotation mapping it to the GSA.

### Review gke_svc_tfcagents
Stateless GKE service deployment
`Open VCode tab ./gke_svc_tfcagents/main.tf`
* TFCB Agent Token - pulled from TFCB vars (map(Objects))
* GKE Namespace, SA

Take a look at the GKE deployment
```
kubectl get namespaces
kubectl config set-context --current --namespace=tfc-team1
kubectl get deployment
kubectl get pods
kubectl get sa
kubectl get sa tfc-team1-dev -o json | jq -r '.metadata.annotations'
kubectl get secret
```

`Open TFCB Browser tab to Settings->Agents`
* Watch Team based agent pools as we kick off the next plans
### Run/Review team1, team2
Run a Plan on both workspaces.  Team1 should run successfully. Team2 should fail.
Team1 and Team2 are running the same IaC.
`Open VCode tab ./gke_tfc_team1/main.tf`
`Open VCode tab ./gke_tfc_team2/main.tf`

Why did Team2 fail?

hint: `review ./gke_ADMIN_IAM/variables.tf` to see the different roles