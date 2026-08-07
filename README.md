# 🚀 RKE2 Downstream Cluster on Harvester

A production-ready Terraform module for provisioning and managing RKE2 Kubernetes downstream clusters on Harvester HCI infrastructure using Rancher Manager.

---

## 📖 Overview

This module automates the end-to-end deployment of downstream RKE2 Kubernetes clusters on Harvester VMs. It handles infrastructure provisioning, node networking via cloud-init (DHCP or static IP), RBAC configuration, and full integration with the **Harvester Cloud Provider**.

### Highlights
* **Harvester Cloud Provider Integration**: Native load balancing and cloud integration using Harvester kubeconfig credentials (`harvester-kubeconfig.yaml`).
* **Custom Node Initialization**: Templated `cloud-init` (Ubuntu 24.04) for Netplan dynamic DHCP or static IP allocation, host FQDNs, firewall policies, and SSH access.
* **Flexible Cluster Topologies**: Multi-node pool topologies with dedicated Control Plane (+ ETCD) and Worker pools.
* **Pluggable Networking**: Easily switch CNI plugins (Cilium, Calico, Canal) and customize Kubernetes versions.
* **Graceful Teardown**: Built-in teardown delay (`time_sleep`) ensures Rancher background finalizers complete before removing credentials.

---

## 📋 Prerequisites

* **Rancher Management Server** with an imported Harvester cluster.
* **Rancher Bearer Token**: Created via Rancher UI (**User Profile** ➔ **Account & API Keys**).
* **Harvester Kubeconfig File**: Saved locally as `harvester-kubeconfig.yaml`.
* **Harvester VM Image**: Ubuntu 24.04 cloud image uploaded to Harvester (e.g. `harvester-public/image-mfv78`).
* **Terraform CLI**: `>= 1.5.0`.

---

## ⚙️ Module Inputs

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `rancher_api_url` | `string` | `""` | Rancher API endpoint URL |
| `rancher_bearer_token` | `string` | `""` | Rancher API Bearer Token *(Sensitive)* |
| `rancher_insecure` | `bool` | `false` | Allow insecure TLS connections to Rancher API |
| `harvester_cluster_name` | `string` | `"harvester"` | Name of the Harvester cluster in Rancher |
| `harvester_cluster_type` | `string` | `"imported"` | Harvester connection type (`"imported"` or `"external"`) |
| `harvester_kubeconfig_path` | `string` | `"./harvester-kubeconfig.yaml"` | Path to Harvester cluster kubeconfig file |
| `clustername` | `string` | `"test-rke2-clus"` | Name of the downstream RKE2 cluster |
| `kubernetes_version` | `string` | `"v1.35.6+rke2r1"` | RKE2 Kubernetes version |
| `cni` | `string` | `"cilium"` | CNI network plugin (`cilium`, `calico`, `canal`, `none`) |
| `use_dhcp` | `bool` | `true` | Enable DHCP for node network interface |
| `control_plane_count` | `number` | `3` | Number of control-plane nodes |
| `control_plane_cpu` | `string` | `"4"` | vCPUs per control-plane node |
| `control_plane_memory` | `string` | `"8"` | Memory (GB) per control-plane node |
| `control_plane_disk_size` | `number` | `60` | Disk size (GB) per control-plane node |
| `worker_count` | `number` | `6` | Number of worker nodes |
| `worker_cpu` | `string` | `"10"` | vCPUs per worker node |
| `worker_memory` | `string` | `"68"` | Memory (GB) per worker node |
| `worker_disk_size` | `number` | `60` | Disk size (GB) per worker node |
| `image` | `string` | `"harvester-public/image-mfv78"` | Harvester VM backing image ID |
| `namespace` | `string` | `"default"` | Harvester VM target namespace |
| `vlan` | `string` | `"harvester-public/vlan172"` | Harvester VM network VLAN |
| `domain` | `string` | `"ati.gov.et"` | Search domain name for FQDN resolution |
| `ssh_user` | `string` | `"eati"` | Node SSH admin user account |

---

## 🚦 Quick Start

### 1. Configure Input Variables

Copy `terraform.tfvars.example` to `terraform.tfvars`:

```hcl
rancher_api_url      = "https://rancher.ati.gov.et"
rancher_bearer_token = "token-xxxxx:xxxxxxxxxxxxxxxxxxxx"
rancher_insecure     = true

harvester_cluster_type    = "imported"
harvester_kubeconfig_path = "./harvester-kubeconfig.yaml"

clustername          = "test-rke2-clus"
cni                  = "cilium"
kubernetes_version   = "v1.35.6+rke2r1"

use_dhcp             = true

control_plane_count  = 3
control_plane_cpu    = "4"
control_plane_memory = "8"
control_plane_disk_size = 60

worker_count         = 6
worker_cpu           = "10"
worker_memory        = "68"
worker_disk_size     = 60

namespace            = "default"
image                = "harvester-public/image-mfv78" # Ubuntu 24.04 Cloud Image
vlan                 = "harvester-public/vlan172"
ssh_user             = "eati"
domain               = "ati.gov.et"
```

### 2. Deploy Cluster

```bash
# Initialize Terraform providers
terraform init

# Review execution plan
terraform plan

# Apply changes to provision cluster
terraform apply
```

---

## 🏗️ Provisioning Architecture

```
1. Rancher API & Local Kubeconfig
   └── Load Harvester credentials from 'harvester-kubeconfig.yaml'

2. Cloud Credential & Machine Configs
   ├── Create Rancher Cloud Credential (rancher2_cloud_credential.harvester)
   ├── Create Control Plane Config (rancher2_machine_config_v2.control_plane)
   └── Create Worker Config (rancher2_machine_config_v2.worker)

3. Provision RKE2 Downstream Cluster
   └── Provision RKE2 Cluster with 3 CP + 6 Worker pools (rancher2_cluster_v2.cluster)
```
