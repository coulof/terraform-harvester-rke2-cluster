# 🚀 RKE2 Downstream Cluster on Harvester

A production-ready Terraform module for provisioning and managing RKE2 Kubernetes downstream clusters on Harvester HCI infrastructure using Rancher Manager.

---

## 📖 Overview

This module automates the end-to-end deployment of downstream RKE2 Kubernetes clusters on Harvester VMs. It handles infrastructure provisioning, node networking via cloud-init (DHCP or static IP), RBAC configuration, recurring S3 ETCD backups, and full integration with the **Harvester Cloud Provider**.

### Highlights
* **Harvester Cloud Provider Integration**: Native load balancing and cloud integration using Harvester kubeconfig credentials (`harvester-kubeconfig.yaml`).
* **Automated ETCD S3 Backups**: Built-in automated recurring ETCD snapshot backups to S3-compatible storage (e.g. SeaweedFS, MinIO) with custom CA certificate support.
* **Custom Node Initialization**: Templated `cloud-init` (Ubuntu 24.04) for Netplan dynamic DHCP or static IP allocation, host FQDNs, firewall policies, and SSH access.
* **Flexible Cluster Topologies**: Multi-node pool topologies with dedicated Control Plane (+ ETCD) and Worker pools or single-node all-in-one test pools.
* **Pluggable Networking**: Easily switch CNI plugins (Cilium, Calico, Canal) and ingress controllers (Traefik, NGINX).
* **Multi-Cluster Workspace Management**: Support for multiple isolated cluster deployments using Terraform Workspaces.
* **Graceful Teardown**: Built-in teardown delay (`time_sleep`) ensures Rancher background finalizers complete before removing credentials.

---

## 📋 Prerequisites

* **Rancher Management Server** with an imported Harvester cluster.
* **Rancher Bearer Token**: Created via Rancher UI (**User Profile** ➔ **Account & API Keys**).
* **Harvester Kubeconfig File**: Saved locally as `harvester-kubeconfig.yaml` or fetched dynamically.
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
| `harvester_fleet_namespace` | `string` | `"fleet-default"` | Fleet namespace of the Harvester cluster in Rancher |
| `harvester_cluster_type` | `string` | `"imported"` | Harvester connection type (`"imported"` or `"external"`) |
| `harvester_kubeconfig_path` | `string` | `"./harvester-kubeconfig.yaml"` | Path to Harvester cluster kubeconfig file |
| `clustername` | `string` | `"test-rke2-clus"` | Name of the downstream RKE2 cluster |
| `kubernetes_version` | `string` | `"v1.35.6+rke2r1"` | RKE2 Kubernetes version |
| `cni` | `string` | `"calico"` | CNI network plugin (`calico`, `cilium`, `canal`, `none`) |
| `ingress_mode` | `string` | `"traefik"` | Ingress controller (`traefik`, `ingress-nginx`, `none`) |
| `control_plane_pool_name` | `string` | `"control-plane"` | Display name of the control plane machine pool |
| `control_plane_count` | `number` | `3` | Number of control-plane nodes |
| `control_plane_cpu` | `string` | `"4"` | vCPUs per control-plane node |
| `control_plane_memory` | `string` | `"8"` | Memory (GB) per control-plane node |
| `control_plane_disk_size` | `number` | `60` | Disk size (GB) per control-plane node |
| `worker_count` | `number` | `6` | Number of worker nodes |
| `worker_cpu` | `string` | `"10"` | vCPUs per worker node |
| `worker_memory` | `string` | `"68"` | Memory (GB) per worker node |
| `worker_disk_size` | `number` | `60` | Disk size (GB) per worker node |
| `use_dhcp` | `bool` | `true` | Enable DHCP for node network interface |
| `master_ip` | `string` | `"172.16.16.10/24"` | Static IP CIDR for master node (when `use_dhcp = false`) |
| `worker_ip` | `string` | `"172.16.16.11/24"` | Static IP CIDR for worker node (when `use_dhcp = false`) |
| `gateway_ip` | `string` | `"172.16.16.1"` | Default network gateway IP |
| `dns_servers` | `list(string)` | `["10.1.10.30", "10.1.10.40"]` | List of DNS server IPs |
| `etcd_s3_enabled` | `bool` | `false` | Enable recurring ETCD S3 backups |
| `etcd_s3_endpoint` | `string` | `""` | S3 endpoint host (e.g. SeaweedFS) |
| `etcd_s3_bucket` | `string` | `""` | S3 bucket name for ETCD snapshots |
| `etcd_s3_access_key` | `string` | `""` | S3 access key ID *(Sensitive)* |
| `etcd_s3_secret_key` | `string` | `""` | S3 secret access key *(Sensitive)* |
| `etcd_s3_region` | `string` | `"us-east-1"` | S3 region |
| `etcd_s3_folder` | `string` | `""` | Subfolder inside S3 bucket (defaults to cluster name) |
| `etcd_s3_skip_ssl_verify` | `bool` | `false` | Skip SSL certificate verification for S3 endpoint |
| `etcd_s3_ca_cert_path` | `string` | `"./caddy-root-ca.cert"` | Path to custom CA cert file for S3 endpoint |
| `etcd_snapshot_schedule_cron` | `string` | `"0 */6 * * *"` | Cron schedule for ETCD snapshots |
| `etcd_snapshot_retention` | `number` | `7` | Number of ETCD snapshots to retain |
| `storage_class` | `string` | `""` | Harvester StorageClass backing VM machine disks |
| `image` | `string` | `"harvester-public/image-mfv78"` | Harvester VM backing image ID |
| `namespace` | `string` | `"default"` | Harvester VM target namespace |
| `vlan` | `string` | `"harvester-public/vlan172"` | Harvester VM network VLAN |
| `domain` | `string` | `"ati.gov.et"` | Search domain name for FQDN resolution |
| `ssh_user` | `string` | `"eati"` | Node SSH admin user account |

---

## 🚦 Quick Start & Deployment

```bash
# Initialize Terraform
terraform init

# Create and select the target cluster workspace
terraform workspace new main-cluster || terraform workspace select main-cluster

# Review plan using cluster variables
terraform plan -var-file="main-cluster.tfvars"

# Deploy cluster
terraform apply -var-file="main-cluster.tfvars"
```

---

## 🏗️ Provisioning Architecture

```
1. Rancher API & Local Kubeconfig
   └── Load Harvester credentials from 'harvester-kubeconfig.yaml'

2. Cloud Credentials & Machine Configs
   ├── Create Rancher Cloud Credential (rancher2_cloud_credential.harvester)
   ├── Create S3 Cloud Credential for ETCD backups (rancher2_cloud_credential.s3)
   ├── Create Control Plane Config (rancher2_machine_config_v2.control_plane)
   └── Create Worker Config (rancher2_machine_config_v2.worker)

3. Provision RKE2 Downstream Cluster
   └── Provision RKE2 Cluster with Control Plane + Worker pools (rancher2_cluster_v2.cluster)
```

---

## 📚 External Documentation & Resources

* [Terraform Rancher2 Provider Documentation](https://registry.terraform.io/providers/rancher/rancher2/latest/docs)
* [`rancher2_cluster_v2` Resource Documentation](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cluster_v2)
* [`rancher2_machine_config_v2` Resource Documentation](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/machine_config_v2)
* [`rancher2_cloud_credential` Resource Documentation](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cloud_credential)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

