resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  _kubectl_cmd = "kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/quick-start-postgres.yaml"
}

# Yes local-exec is unfortunate.
# As of 7/22/2022, this did not work:
# https://registry.terraform.io/providers/gavinbunney/kubectl/1.14.0
# The main challenge is that the Argo yaml contains multiple k8s resources, and terraform does not accept that natively.
resource "null_resource" "argo-quick-start-installation" {
  triggers = {
    cmd = local._kubectl_cmd
  }
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell"] : null
    command = local.is_windows ? "$env:KUBECONFIG='${local_file.kubeconfig.filename}'; ${local._kubectl_cmd}" : "KUBECONFIG=${local_file.kubeconfig.filename} ${local._kubectl_cmd}"
  }
}
