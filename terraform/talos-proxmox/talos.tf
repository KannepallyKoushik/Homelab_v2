# ─── Machine Secrets ──────────────────────────────────────────────────────────
# This resource generates all cluster secrets (CA, etcd CA, etc.) once.
# The secrets live in Terraform state — protect your state file.
# Rotate secrets only via `talosctl rotate-ca` — do NOT taint this resource on
# a live cluster unless you know what you're doing.

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# ─── Control Plane Machine Configuration ──────────────────────────────────────

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cp_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  # Patches are merged on top of the generated base config.
  # Order matters: later patches override earlier ones.
  config_patches = [
    templatefile("${path.module}/patches/controlplane.yaml.tpl", {
      cp_ip                 = var.cp_ip
      gateway               = var.network_gateway
      subnet_prefix         = var.network_subnet_prefix
      dns_servers           = var.dns_servers
      talos_installer_image = var.talos_installer_image
      pod_cidr              = var.cluster_pod_cidr
      service_cidr          = var.cluster_service_cidr
    })
    # ,
    # yamlencode({
    #   machine = {
    #     network = {
    #       hostname = "talos-cp"
    #     }
    #   }
    # })
  ]
}

# ─── Worker Machine Configuration ─────────────────────────────────────────────

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cp_ip}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/patches/worker.yaml.tpl", {
      worker_ip             = var.worker_ip
      gateway               = var.network_gateway
      subnet_prefix         = var.network_subnet_prefix
      dns_servers           = var.dns_servers
      talos_installer_image = var.talos_installer_image
    })
    # ,
    # yamlencode({
    #   machine = {
    #     network = {
    #       hostname = "talos-worker1"
    #     }
    #   }
    # })
  ]
}

# ─── Apply Control Plane Config ───────────────────────────────────────────────
# Connects to the Talos API on the live booted node and pushes the machine config.
# Talos will validate, install itself to disk, and reboot.
# This resource will wait until the node is reachable on port 50000.

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.cp_ip
  endpoint                    = var.cp_ip

  # Talos API may take a minute to come up after the VM boots from ISO.
  # `tofu apply` will retry — be patient.
  apply_mode = "reboot"

  depends_on = [proxmox_virtual_environment_vm.talos_cp]
}

# ─── Apply Worker Config ──────────────────────────────────────────────────────

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = var.worker_ip
  endpoint                    = var.worker_ip

  apply_mode = "reboot"

  depends_on = [proxmox_virtual_environment_vm.talos_worker]
}

# ─── Bootstrap etcd ───────────────────────────────────────────────────────────
# Runs `talosctl bootstrap` on the control plane — kicks off etcd and the k8s
# control plane components. Run ONCE per cluster lifetime.
# If you re-run this on an existing cluster, Talos will reject it safely.

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.cp_ip
  endpoint             = var.cp_ip

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# ─── Fetch kubeconfig ─────────────────────────────────────────────────────────
# Pulls the admin kubeconfig once the API server is healthy.

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.cp_ip
  endpoint             = var.cp_ip

  depends_on = [talos_machine_bootstrap.this]
}

# ─── Generate talosconfig ─────────────────────────────────────────────────────

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.cp_ip]
  nodes                = [var.cp_ip, var.worker_ip]
}
