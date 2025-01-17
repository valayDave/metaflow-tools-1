output "END_USER_SETUP_INSTRUCTIONS" {
  value = <<EOT
V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V=V
Setup instructions for END USERS (e.g. someone running Flows vs the new stack):
-------------------------------------------------------------------------------
There are three steps:
1. Ensuring Azure access
2. Configure Metaflow
3. Run port forwards
4. Install necessary Azure Python SDK libraries


STEP 1: Ensure you have sufficient access to these Azure resources on your local workstation:

- AKS cluster ("${local.kubernetes_cluster_name}") ("Azure Kubernetes Service Contributor")
- Azure Storage ("${local.storage_container_name}" in the storage account "${local.storage_account_name}") ("Storage Blob Data Contributor")

You can use "az login" as a sufficiently capabable account. To see the credentials for the service principal
(created by terraform) that is capable, run this:

$ terraform output -raw SERVICE_PRINCIPAL_CREDENTIALS

Use the credentials with "az login"

$ az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

Configure your local Kubernetes context to point to the the right Kubernetes cluster:

$ az aks get-credentials --resource-group ${data.azurerm_kubernetes_cluster.default.resource_group_name} --name ${data.azurerm_kubernetes_cluster.default.name}

STEP 2: Configure Metaflow:

$ metaflow configure azure
$ metaflow configure kubernetes

Use these values when prompted:

METAFLOW_DATASTORE_SYSROOT_AZURE=${local.metaflow_datastore_sysroot_azure}
METAFLOW_AZURE_STORAGE_BLOB_SERVICE_ENDPOINT=${data.azurerm_storage_account.default.primary_blob_endpoint}
METAFLOW_KUBERNETES_SECRETS=${local.metaflow_kubernetes_secrets}
METAFLOW_SERVICE_URL=http://127.0.0.1:8080/
METAFLOW_SERVICE_INTERNAL_URL=http://metadata-service.default:8080/
[For Argo only] METAFLOW_KUBERNETES_NAMESPACE=argo

Note: you can skip METAFLOW_SERVICE_AUTH_KEY (leave it blank)

STEP 3: Setup port-forwards to services running on Kubernetes:

option 1 - run kubectl's manually:
$ kubectl port-forward deployment/metadata-service 8080:8080
$ kubectl port-forward deployment/metaflow-ui-backend-service 8083:8083
$ kubectl port-forward deployment/metadata-service 3000:3000
$ kubectl port-forward -n argo deployment/argo-server 2746:2746

option 2 - this script manages the same port-forwards for you (and prevents timeouts)

$ python metaflow-tools/scripts/forward_metaflow_ports.py [--include-argo]

STEP 4: Install Azure Python SDK
$ pip install azure-storage-blob azure-identity

#^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^
EOT
}

output "SERVICE_PRINCIPAL_CREDENTIALS" {
  value = <<EOT
AZURE_TENANT_ID=${module.infra.service_principal_tenant_id}
AZURE_CLIENT_ID=${module.infra.service_principal_client_id}
AZURE_CLIENT_SECRET=${module.infra.service_principal_client_secret}
EOT
  sensitive = true
}