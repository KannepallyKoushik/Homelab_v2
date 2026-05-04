# ─── talosconfig ──────────────────────────────────────────────────────────────
# Merge into ~/.talos/config or export TALOSCONFIG=./talosconfig

output "talosconfig" {
  description = "Talos client configuration (talosconfig). Handle as a secret."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

# ─── kubeconfig ───────────────────────────────────────────────────────────────
# Merge into ~/.kube/config or export KUBECONFIG=./kubeconfig

output "kubeconfig" {
  description = "Kubernetes admin kubeconfig. Handle as a secret."
  value       = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

# ─── Node IPs ─────────────────────────────────────────────────────────────────

output "control_plane_ip" {
  description = "Control plane node IP"
  value       = var.cp_ip
}

output "worker_ip" {
  description = "Worker node IP"
  value       = var.worker_ip
}

# ─── Quick-start commands ─────────────────────────────────────────────────────

output "usage_instructions" {
  description = "Commands to use after apply"
  value       = <<-EOT
    # Save configs
    tofu output -raw talosconfig > talosconfig
    tofu output -raw kubeconfig  > kubeconfig

    # # Use talosctl
    # export TALOSCONFIG=./talosconfig
    # talosctl health --nodes ${var.cp_ip}
    # talosctl dashboard --nodes ${var.cp_ip}

    # # Use kubectl
    # export KUBECONFIG=./kubeconfig
    # kubectl get nodes -o wide
    # kubectl get pods -n kube-system

    # # Verify Cilium
    # kubectl -n kube-system rollout status daemonset/cilium
    # kubectl -n kube-system exec ds/cilium -- cilium status
  EOT
}
