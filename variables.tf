variable "rancher_api_url" {
  type        = string
  default     = ""
  description = "Rancher API endpoint to manage your cluster"
}

variable "rancher_bearer_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Rancher Bearer Token"
}

variable "rancher_insecure" {
  type        = bool
  default     = false
  description = "Allow insecure connections to the Rancher API"
}

variable "harvester_cluster_name" {
  type        = string
  default     = "harvester"
  description = "Name of the imported Harvester cluster in Rancher"
}

variable "harvester_fleet_namespace" {
  type        = string
  default     = "fleet-default"
  description = "Fleet namespace of the imported Harvester cluster in Rancher (e.g. fleet-default or fleet-local)"
}

variable "harvester_cluster_type" {
  type        = string
  default     = "imported"
  description = "Harvester cluster connection type in Rancher ('imported' or 'external')"
}

variable "harvester_kubeconfig_path" {
  type        = string
  default     = "./harvester-kubeconfig.yaml"
  description = "Path to the Harvester cluster kubeconfig file. If file does not exist, fetched automatically from Rancher."
}

variable "kubernetes_version" {
  type        = string
  default     = "v1.35.6+rke2r1"
  description = "Kubernetes version for the downstream cluster"
}

variable "cni" {
  type        = string
  default     = "calico"
  description = "CNI network plugin for the RKE2 downstream cluster (e.g. calico, cilium, canal, none)"
}

variable "image" {
  type        = string
  default     = "harvester-public/image-mfv78"
  description = "Harvester VM image ID (Display name: noble-24-04-server-cloudimg-amd64)"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Harvester VM namespace"
}

variable "clustername" {
  type        = string
  default     = "test-rke2-clus"
  description = "Name of the downstream RKE2 cluster"
}

variable "vlan" {
  type        = string
  default     = "harvester-public/vlan172"
  description = "Harvester VM network VLAN name"
}

variable "ssh_user" {
  type        = string
  default     = "eati"
  description = "SSH username for the VM nodes"
}

variable "domain" {
  type        = string
  default     = "ati.gov.et"
  description = "Domain name for FQDN"
}

variable "use_dhcp" {
  type        = bool
  default     = true
  description = "Use DHCP for node IP allocation instead of static IP addresses"
}

variable "control_plane_count" {
  type        = number
  default     = 3
  description = "Number of control-plane (master) nodes"
}

variable "control_plane_cpu" {
  type        = string
  default     = "4"
  description = "vCPU count for control-plane nodes"
}

variable "control_plane_memory" {
  type        = string
  default     = "8"
  description = "Memory size (in GB) for control-plane nodes"
}

variable "control_plane_disk_size" {
  type        = number
  default     = 60
  description = "Disk size (in GB) for control-plane nodes"
}

variable "worker_count" {
  type        = number
  default     = 6
  description = "Number of worker nodes"
}

variable "worker_cpu" {
  type        = string
  default     = "10"
  description = "vCPU count for worker nodes"
}

variable "worker_memory" {
  type        = string
  default     = "68"
  description = "Memory size (in GB) for worker nodes"
}

variable "worker_disk_size" {
  type        = number
  default     = 60
  description = "Disk size (in GB) for worker nodes"
}

variable "master_ip" {
  type        = string
  default     = "172.16.16.10/24"
  description = "Static IP CIDR for master node"
}

variable "worker_ip" {
  type        = string
  default     = "172.16.16.11/24"
  description = "Static IP CIDR for worker node"
}

variable "gateway_ip" {
  type        = string
  default     = "172.16.16.1"
  description = "Default network gateway IP"
}

variable "dns_servers" {
  type        = list(string)
  default     = ["10.1.10.30", "10.1.10.40"]
  description = "List of DNS server IPs"
}
