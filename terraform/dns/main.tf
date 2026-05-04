terraform {
  required_providers {
    pfsense = {
      source = "marshallford/pfsense"
      version = "0.15.0"
    }
  }
}

provider "pfsense" {
  # Configuration options
  url      = "https://pfsense.kannepally.me/"
  username = "kannepallykoushik"
  password = var.pfsense_password
  tls_skip_verify = true
}

# ------------------- Hosts -------------------
resource "pfsense_dnsresolver_hostoverride" "pve_node1" {
  host        = "pve-node1"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.14"]
  description = "PVE Node 1"
}

resource "pfsense_dnsresolver_hostoverride" "pve_node2" {
  host        = "pve-node2"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.16"]
  description = "PVE Node 2"
}

# ------------------- VMs -------------------

resource "pfsense_dnsresolver_hostoverride" "linux-learn-ubuntu" {
  host        = "linux-learn"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.15"]
  description = "Linux Learn Ubuntu VM"
}

resource "pfsense_dnsresolver_hostoverride" "talos-cp" {
  host        = "talos-cp"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.151"]
  description = "Talos Control Plane VM"
}

resource "pfsense_dnsresolver_hostoverride" "talos-worker1" {
  host        = "talos-worker1"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.152"]
  description = "Talos Worker 1 VM"
}
