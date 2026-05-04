# ─── Proxmox Connection ───────────────────────────────────────────────────────

variable "proxmox_api_url" {
  description = "Proxmox API endpoint. Example: https://192.168.1.10:8006"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the format USER@REALM!TOKENID=SECRET"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (true if using a self-signed cert)"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Target Proxmox node name"
  type        = string
  default     = "pve-node2"
}

# ─── Cluster Identity ─────────────────────────────────────────────────────────

variable "cluster_name" {
  description = "Talos / Kubernetes cluster name"
  type        = string
  default     = "talos-proxmox-cluster"
}

variable "talos_version" {
  description = "Talos version string (used in machine config generation)"
  type        = string
  default     = "v1.12.3"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy"
  type        = string
  default     = "v1.32.3"
}

# ─── Network ──────────────────────────────────────────────────────────────────

variable "network_bridge" {
  description = "Proxmox Linux bridge to attach VMs to"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "Default gateway for the VM network"
  type        = string
}

variable "network_subnet_prefix" {
  description = "CIDR prefix length for the VM subnet (e.g. 24 for /24)"
  type        = number
  default     = 24
}

variable "dns_servers" {
  description = "DNS servers configured on the Talos nodes"
  type        = list(string)
  default     = ["192.168.1.1"]
}

# ─── Control Plane VM ─────────────────────────────────────────────────────────

variable "cp_vm_id" {
  description = "Proxmox VM ID for the control plane node"
  type        = number
  default     = 200
}

variable "cp_ip" {
  description = "Static IP for the control plane node (no prefix, e.g. 192.168.1.50)"
  type        = string
}

variable "cp_cpu_cores" {
  description = "Number of vCPU cores for the control plane"
  type        = number
  default     = 3
}

variable "cp_memory_mb" {
  description = "RAM in MB for the control plane"
  type        = number
  default     = 4096
}

variable "cp_disk_size_gb" {
  description = "OS disk size in GB for the control plane"
  type        = number
  default     = 50
}

# ─── Worker VM ────────────────────────────────────────────────────────────────

variable "worker_vm_id" {
  description = "Proxmox VM ID for the worker node"
  type        = number
  default     = 201
}

variable "worker_ip" {
  description = "Static IP for the worker node (no prefix, e.g. 192.168.1.51)"
  type        = string
}

variable "worker_cpu_cores" {
  description = "Number of vCPU cores for the worker"
  type        = number
  default     = 4
}

variable "worker_memory_mb" {
  description = "RAM in MB for the worker"
  type        = number
  default     = 8192
}

variable "worker_disk_size_gb" {
  description = "OS disk size in GB for the worker"
  type        = number
  default     = 100
}

# ─── Storage ──────────────────────────────────────────────────────────────────

variable "proxmox_iso_datastore" {
  description = "Proxmox datastore where the Talos ISO lives"
  type        = string
  default     = "local"
}

variable "talos_iso_filename" {
  description = "Filename of the Talos ISO as uploaded to Proxmox"
  type        = string
  default     = "nocloud-amd-1.12.3.iso"
}

variable "vm_disk_datastore" {
  description = "Proxmox datastore for VM OS disks"
  type        = string
  default     = "local-lvm"
}

# ─── Talos Installer Image ────────────────────────────────────────────────────

variable "talos_installer_image" {
  description = "Talos factory installer image reference written into machine config"
  type        = string
  default     = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.3"
}

# ─── Cilium ───────────────────────────────────────────────────────────────────

variable "cilium_chart_version" {
  description = "Cilium Helm chart version"
  type        = string
  default     = "1.17.3"
}

variable "cluster_pod_cidr" {
  description = "Pod CIDR for the Kubernetes cluster"
  type        = string
  default     = "10.244.0.0/16"
}

variable "cluster_service_cidr" {
  description = "Service CIDR for the Kubernetes cluster"
  type        = string
  default     = "10.96.0.0/12"
}
