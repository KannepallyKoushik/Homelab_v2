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

# ------------------- Services -------------------

resource "pfsense_dnsresolver_domainoverride" "pve_gui" {
  domain      = "pve.kannepally.me"
  ip_address  = "192.168.11.14:8006"
  description = "PVE GUI"
}
