locals {
  harvester_kc = fileexists(var.harvester_kubeconfig_path) ? file(var.harvester_kubeconfig_path) : data.rancher2_cluster_v2.harvester.kube_config
}

resource "rancher2_cloud_credential" "harvester" {
  name = "${var.clustername}-harvester"
  harvester_credential_config {
    cluster_id         = var.harvester_cluster_type == "imported" ? data.rancher2_cluster_v2.harvester.cluster_v1_id : null
    cluster_type       = var.harvester_cluster_type
    kubeconfig_content = local.harvester_kc
  }
}

resource "rancher2_machine_config_v2" "all_in_one" {
  generate_name = "node-"
  harvester_config {
    vm_namespace = var.namespace
    cpu_count    = "4"
    memory_size  = "8"
    # Backing image: noble-24-04-server-cloudimg-amd64
    disk_info = jsonencode({
      disks = [{
        imageName = length(split("/", var.image)) > 1 ? var.image : "${var.namespace}/${var.image}"
        size      = 40
        bootOrder = 1
      }]
    })
    network_info = jsonencode({
      interfaces = [{
        networkName = var.vlan
      }]
    })
    ssh_user = var.ssh_user
    user_data = templatefile("${path.module}/ubuntu-24-04-base.yaml.tftpl", {
      hostname = var.clustername
      domain   = var.domain
    })
    network_data = templatefile("${path.module}/ubuntu-24-04-base-net-data-vlan172.yaml.tftpl", {
      ip_address  = var.master_ip
      gateway     = var.gateway_ip
      dns_servers = var.dns_servers
      domain      = var.domain
    })
  }
}

resource "rancher2_cluster_v2" "cluster" {
  name               = var.clustername
  kubernetes_version = var.kubernetes_version

  rke_config {
    machine_pools {
      name                         = "all-in-one"
      cloud_credential_secret_name = rancher2_cloud_credential.harvester.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = true
      quantity                     = 1

      machine_config {
        kind = rancher2_machine_config_v2.all_in_one.kind
        name = rancher2_machine_config_v2.all_in_one.name
      }
    }

    machine_selector_config {
      config = jsonencode({
        cloud-provider-config = local.harvester_kc
        cloud-provider-name   = "harvester"
      })
    }

    machine_global_config = yamlencode({
      cni = var.cni
    })

    chart_values = <<EOF
harvester-cloud-provider:
  global:
    cattle:
      clusterName: "${var.clustername}"
  cloudConfigPath: /var/lib/rancher/rke2/etc/config-files/cloud-provider-config
  kube-vip:
    tolerations:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
      operator: Exists
    - effect: NoExecute
      key: node-role.kubernetes.io/etcd
      operator: Exists
    - effect: NoExecute
      key: CriticalAddonsOnly
      operator: Exists
EOF
  }
}
