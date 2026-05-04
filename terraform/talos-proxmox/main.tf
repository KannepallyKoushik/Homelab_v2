terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}

# ─── Proxmox Provider ─────────────────────────────────────────────────────────
# Uses bpg/proxmox — the most feature-complete Proxmox provider for Terraform/OpenTofu.
# Authenticates with an API token (never use root credentials for automation).

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}

# ─── Talos Provider ───────────────────────────────────────────────────────────
# siderolabs/talos provider — generates machine configs and manages the lifecycle
# of Talos nodes without SSH. All interaction is via the Talos API (port 50000).

provider "talos" {}

# ─── Helm Provider ────────────────────────────────────────────────────────────
# Configured AFTER the cluster is bootstrapped using the kubeconfig that the
# talos provider pulls from the cluster.

provider "helm" {
  kubernetes {
    host                   = "https://${var.cp_ip}:6443"
    client_certificate     = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
}
