# Homelab Documentation

This directory contains the build journal for my homelab.

The documentation is intentionally written in **chronological order** to match the exact sequence I follow while deploying and expanding the environment. Each document depends on decisions and outcomes from earlier steps, so the best experience is to read and execute from top to bottom.

## How To Use This Documentation

1. Start with the first document in the sequence.
2. Complete each step before moving to the next one.
3. Use later documents only after the prerequisites in earlier documents are finished.

## Sequential Structure (Example)

The documentation flow follows a step-by-step progression like this:

1. Setting up pfSense firewall, configuring WAN and LANs.
2. Setting up Proxmox nodes.
3. Setting up Talos Kubernetes cluster.
4. Continuing with additional services and automation in the same order they are deployed.

This means the folder is not just a set of standalone notes. It is a **deployment timeline** that mirrors the real homelab implementation journey from foundation components to higher-level platform services.

## Why This Order Matters

- Network and firewall setup must exist before hypervisors and cluster nodes are reachable.
- Proxmox infrastructure must be ready before Talos and Kubernetes can be provisioned.
- Platform and application layers are documented only after core infrastructure is stable.

Following this order helps avoid dependency issues and keeps the setup reproducible.
