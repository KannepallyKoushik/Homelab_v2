machine:
  # ── Installer image ──────────────────────────────────────────────────────────
  install:
    image: ${talos_installer_image}
    disk: /dev/sda
    bootloader: true
    wipe: false

  # ── Static network configuration ─────────────────────────────────────────────
  network:
    nameservers: ${jsonencode(dns_servers)}
    interfaces:
      - interface: eth0
        dhcp: false
        addresses:
          - ${worker_ip}/${subnet_prefix}
        routes:
          - network: 0.0.0.0/0
            gateway: ${gateway}

  # ── Time ─────────────────────────────────────────────────────────────────────
  time:
    servers:
      - time.cloudflare.com

  # ── Sysctls and modules for Cilium ───────────────────────────────────────────
  sysctls:
    net.core.bpf_jit_harden: "1"

  kernel:
    modules:
      - name: br_netfilter
      - name: ip_tables
