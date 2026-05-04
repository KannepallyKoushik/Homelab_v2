machine:
  # ── Installer image from Talos factory (your custom schematic) ──────────────
  install:
    image: ${talos_installer_image}
    disk: /dev/sda
    bootloader: true
    wipe: false

  # ── Static network configuration ────────────────────────────────────────────
  network:
    nameservers: ${jsonencode(dns_servers)}
    interfaces:
      - interface: eth0
        dhcp: false
        addresses:
          - ${cp_ip}/${subnet_prefix}
        routes:
          - network: 0.0.0.0/0
            gateway: ${gateway}

  # ── Time (NTP) ──────────────────────────────────────────────────────────────
  time:
    servers:
      - time.cloudflare.com

  # ── Sysctls needed by Cilium (eBPF / kube-proxy replacement) ───────────────
  sysctls:
    net.core.bpf_jit_harden: "1"

  # ── Kernel modules required by Cilium ───────────────────────────────────────
  kernel:
    modules:
      - name: br_netfilter
      - name: ip_tables

cluster:
  # ── Cluster network: CNI = none (we install Cilium ourselves) ────────────────
  network:
    podSubnets:
      - ${pod_cidr}
    serviceSubnets:
      - ${service_cidr}
    cni:
      name: none           # ← disables Flannel; Cilium is installed via Helm

  # ── Disable kube-proxy (Cilium replaces it via eBPF) ────────────────────────
  proxy:
    disabled: true

  # ── Advertise additional SANs for the API server cert ───────────────────────
  apiServer:
    certSANs:
      - ${cp_ip}
      - talos-cp
      - localhost
      - 127.0.0.1

  # ── etcd: advertise the correct IP ──────────────────────────────────────────
  etcd:
    advertisedSubnets:
      - ${cp_ip}/32
