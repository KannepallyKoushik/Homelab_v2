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
  username = "admin"
  password = var.pfsense_password
  tls_skip_verify = true
}

resource "pfsense_dnsresolver_hostoverride" "pve_node1" {
  host        = "pve-node1"
  domain      = "kannepally.me"
  ip_addresses  = ["192.168.11.14"]
  description = "PVE Node 1"
}