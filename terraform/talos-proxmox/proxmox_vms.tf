# ─── Locals ───────────────────────────────────────────────────────────────────

locals {
  iso_file_id = "${var.proxmox_iso_datastore}:iso/${var.talos_iso_filename}"
}

# ─── Control Plane VM ─────────────────────────────────────────────────────────
# Boot order: disk first, CDROM fallback.
# On first boot the disk is empty → BIOS falls through to ISO → Talos live env starts.
# After talos_machine_configuration_apply runs and Talos installs itself to /dev/sda,
# the node reboots and boots from disk — ISO is no longer needed but is harmless to leave.

resource "proxmox_virtual_environment_vm" "talos_cp" {
  name      = "talos-cp"
  node_name = var.proxmox_node
  vm_id     = var.cp_vm_id
  tags      = ["talos", "controlplane", "kubernetes"]

  on_boot = true

  # ── CPU ──
  cpu {
    cores   = var.cp_cpu_cores
    sockets = 1
    type    = "x86-64-v2-AES"  # modern baseline; change to "host" if you don't live-migrate
    numa    = false
  }

  # ── Memory ──
  memory {
    dedicated = var.cp_memory_mb
    floating  = 0  # no memory ballooning — Talos doesn't support the balloon driver
  }

  # ── Boot disk ──
  disk {
    datastore_id = var.vm_disk_datastore
    interface    = "scsi0"
    size         = var.cp_disk_size_gb
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  # ── Talos ISO ──
  cdrom {
    enabled   = true
    file_id   = local.iso_file_id
    interface = "ide2"
  }

  # ── Network ──
  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    firewall = false
  }

  # ── SCSI controller: virtio-scsi-single gives the best IOPS for a single disk ──
  scsi_hardware = "virtio-scsi-single"

  # ── Operating system hint ──
  operating_system {
    type = "l26"  # Linux 5.x+ kernel
  }

  # ── Boot order: try disk first, fall back to CDROM ──
  boot_order = ["scsi0", "ide2"]

  # ── VGA ──
  vga {
    type   = "qxl"
    memory = 16
  }

  # ── Agent: disable — Talos does not run qemu-guest-agent ──
  agent {
    enabled = true
    trim    = true   # allows guest to report disk trim support
    type    = "virtio"
  }

  lifecycle {
    # Prevent accidental destruction of a running cluster node
    prevent_destroy = false

    # Ignore post-boot changes to the CDROM — Talos removes it after install
    ignore_changes = [cdrom]
  }
}

# ─── Worker VM ────────────────────────────────────────────────────────────────

resource "proxmox_virtual_environment_vm" "talos_worker" {
  name      = "talos-worker1"
  node_name = var.proxmox_node
  vm_id     = var.worker_vm_id
  tags      = ["talos", "worker", "kubernetes"]

  on_boot = true

  cpu {
    cores   = var.worker_cpu_cores
    sockets = 1
    type    = "x86-64-v2-AES"
    numa    = false
  }

  memory {
    dedicated = var.worker_memory_mb
    floating  = 0
  }

  disk {
    datastore_id = var.vm_disk_datastore
    interface    = "scsi0"
    size         = var.worker_disk_size_gb
    file_format  = "raw"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  cdrom {
    enabled   = true
    file_id   = local.iso_file_id
    interface = "ide2"
  }

  network_device {
    bridge   = var.network_bridge
    model    = "virtio"
    firewall = false
  }

  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  boot_order = ["scsi0", "ide2"]

  vga {
    type   = "qxl"
    memory = 16
  }

  agent {
    enabled = true
    trim    = true   # allows guest to report disk trim support
    type    = "virtio"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [cdrom]
  }
}
