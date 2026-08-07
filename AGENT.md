# 🤖 AI Agent Guidelines (`AGENT.md`)

This document provides context, architectural rules, and conventions for AI agents and automated tools working in this repository.

---

## 📌 Project Overview

This repository contains a standalone, production-ready Terraform module (`terraform-harvester-rke2-cluster`) that provisions RKE2 downstream Kubernetes clusters on Harvester HCI infrastructure using Rancher Manager.

---

## 📂 File Architecture

| File | Purpose |
| :--- | :--- |
| `provider.tf` | Required provider constraints (`rancher/rancher2 >= 14.0.0`) and provider configuration. |
| `cluster.tf` | Provisions `rancher2_cloud_credential`, `rancher2_machine_config_v2`, and `rancher2_cluster_v2`. |
| `data.tf` | Queries Rancher for the imported Harvester cluster details (`data.rancher2_cluster_v2.harvester`). |
| `variables.tf` | Input variable declarations with strict types, defaults, and descriptions. |
| `terraform.tfvars.example` | Template input values for deployment. |
| `terraform.tfvars` | Local user input values (gitignored). |
| `ubuntu-24-04-base.yaml.tftpl` | Cloud-init `user-data` template for Ubuntu 24.04 nodes (hostname, FQDN, SSH user). |
| `ubuntu-24-04-base-net-data-vlan172.yaml.tftpl` | Netplan `network-data` template for static IP networking. |
| `harvester-kubeconfig.yaml` | Native Harvester cluster kubeconfig (gitignored). |
| `.gitignore` | Prevents state, `.tfvars`, and kubeconfig files from being committed. |

---

## 📐 Core Engineering Conventions

1. **Strict Module Isolation**:
   * **Never reference parent directories (`../`)**. All files, scripts, and templates must reside within the module directory.
2. **Native Harvester Kubeconfig**:
   * Always use a native Harvester cluster kubeconfig (e.g., from `/etc/rancher/rke2/rke2.yaml` on a Harvester node) for `harvester_kubeconfig_path`. Do not use Rancher UI session tokens (`kubeconfig-user-...`), which trigger Rancher bug [#11129](https://github.com/harvester/harvester/issues/11129).
3. **HCL2 Data Encoding**:
   * Always prefer native `jsonencode({...})` and `yamlencode({...})` for JSON and YAML payloads over multiline heredocs to prevent escaping bugs and indentation errors.
4. **Official Terminology**:
   * Use **Harvester Cloud Provider** (CCM) and **Harvester CSI Driver** per official [Harvester Documentation](https://docs.harvesterhci.io/v1.8/rancher/cloud-provider). Do not confuse CCM with CSI.
5. **Security & Secrets**:
   * Never commit `.tfvars`, API keys, bearer tokens, or `.yaml` kubeconfig files. Ensure `.gitignore` covers all sensitive artifacts.

---

## 🛠️ Verification Commands

```bash
# Check code formatting
terraform fmt -check

# Validate configuration syntax
terraform validate

# Perform a dry-run plan
terraform plan
```
