# ─── Cilium CNI ───────────────────────────────────────────────────────────────
# Installed via Helm AFTER the cluster is bootstrapped.
# The machine config patches (patches/controlplane.yaml.tpl) already:
#   1. Set cluster.network.cni.name = "none"  → disables flannel
#   2. Set cluster.proxy.disabled = true       → disables kube-proxy
#
# Cilium runs in kube-proxy replacement mode (eBPF-native), which is the
# recommended setup for Talos. This gives you:
#   - Full NetworkPolicy enforcement
#   - Built-in load balancing (no iptables)
#   - Hubble observability (enable separately when ready)

resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = var.cilium_chart_version
  namespace        = "kube-system"
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 600  # 10 min — first pull can be slow in a homelab

  # kube-proxy replacement — required when kube-proxy is disabled in Talos
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }

  # Point Cilium at the API server directly (needed for kube-proxy replacement)
  set {
    name  = "k8sServiceHost"
    value = var.cp_ip
  }
  set {
    name  = "k8sServicePort"
    value = "6443"
  }

  # IPAM mode: kubernetes uses the pod CIDR assigned to each node by the scheduler
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }

  # Required for Talos — enables the seccomp-operator compatible security context
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }

  # Required on Talos — mounts cgroup correctly
  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }

  # NodePort + HostPort via eBPF
  set {
    name  = "nodePort.enabled"
    value = "true"
  }
  set {
    name  = "hostPort.enabled"
    value = "true"
  }

  # Hubble relay (optional but useful — enable when you want observability)
  set {
    name  = "hubble.relay.enabled"
    value = "false"
  }
  set {
    name  = "hubble.ui.enabled"
    value = "false"
  }

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker,
    data.talos_cluster_kubeconfig.this,
  ]
}
