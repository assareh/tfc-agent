#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source GCP Credentials into your shell environment
if [[ ! -d /tmp ]]; then
  mkdir -p /tmp
fi

echo ${GOOGLE_CREDENTIALS} > /tmp/credential_key.json

# Using zone for the region in tf makes smaller GKS footprint
client_email=$(jq -r '.client_email' < /tmp/credential_key.json) || echo ${GOOGLE_CREDENTIALS} > /tmp/credential_key.json
gcp_region=$(terraform output region)
gcp_zone=$(terraform output zone)
gcp_project=$(terraform output gcp_project)
gcp_cluster_name=$(terraform output kubernetes_cluster_name)
gcp_gke_context=$(terraform output context)

# Authenticate to GKE cluster
if [[ ! $(gcloud auth list | grep ${client_email}) ]]; then
  gcloud auth activate-service-account --key-file=/tmp/credential_key.json
  gcloud config set project ${gcp_project}
  gcloud config set compute/region ${gcp_region}
  gcloud container clusters get-credentials ${gcp_cluster_name} --region ${gcp_zone}
else
  gcloud container clusters get-credentials ${gcp_cluster_name} --region ${gcp_zone}
fi

# Create Kubernetes secret with the GOOGLE_CREDENTIALS for GCP Auto-Unseal.
#if [[ ! $(kubectl get secret kms-creds 2>/dev/null) ]]; then 
#    kubectl create secret generic kms-creds --from-file=/tmp/credential_key.json
#    echo "Secret created to support Auto Unseal with GCP KMS"
#else 
#    echo "Secret: exists to support Auto Unseal with GCP KMS"; 
#fi

# Set Kubernetes context for current GKE cluster
#if [[ ! $(kubectl config get-contexts -o=name | grep -w ${gcp_cluster_name}) ]]; then
##  # Rename context to $gcp_cluster_name for simplicity
#  kubectl config rename-context ${gcp_gke_context} ${gcp_cluster_name}
#fi
kubectl config use-context ${gcp_gke_context}

# kubectl config current-context
# kubectl config view -minify
# kubectl config get-contexts -o=name