locals {
  harvester_kc = fileexists(var.harvester_kubeconfig_path) ? file(var.harvester_kubeconfig_path) : data.rancher2_cluster_v2.harvester.kube_config

  dhcp_network_data = templatefile("${path.module}/ubuntu-24-04-dhcp-net-data.yaml.tftpl", {})
  static_network_data = templatefile("${path.module}/ubuntu-24-04-base-net-data-vlan172.yaml.tftpl", {
    ip_address  = var.master_ip
    gateway     = var.gateway_ip
    dns_servers = var.dns_servers
    domain      = var.domain
  })

  network_data = var.use_dhcp ? local.dhcp_network_data : local.static_network_data
}

resource "time_sleep" "wait_for_cluster_deletion" {
  destroy_duration = "45s"

  depends_on = [rancher2_cluster_v2.cluster]
}

resource "rancher2_cloud_credential" "harvester" {
  name = "${var.clustername}-harvester"
  harvester_credential_config {
    cluster_id         = var.harvester_cluster_type == "imported" ? data.rancher2_cluster_v2.harvester.cluster_v1_id : null
    cluster_type       = var.harvester_cluster_type
    kubeconfig_content = local.harvester_kc
  }

  depends_on = [time_sleep.wait_for_cluster_deletion]
}

resource "rancher2_machine_config_v2" "control_plane" {
  generate_name = "${var.clustername}-cp-"
  harvester_config {
    vm_namespace = var.namespace
    cpu_count    = var.control_plane_cpu
    memory_size  = var.control_plane_memory
    disk_info = jsonencode({
      disks = [{
        imageName = length(split("/", var.image)) > 1 ? var.image : "${var.namespace}/${var.image}"
        size      = var.control_plane_disk_size
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
      hostname = "${var.clustername}-cp"
      domain   = var.domain
      ssh_user = var.ssh_user
    })
    network_data = local.network_data
  }
}

resource "rancher2_machine_config_v2" "worker" {
  generate_name = "${var.clustername}-worker-"
  harvester_config {
    vm_namespace = var.namespace
    cpu_count    = var.worker_cpu
    memory_size  = var.worker_memory
    disk_info = jsonencode({
      disks = [{
        imageName = length(split("/", var.image)) > 1 ? var.image : "${var.namespace}/${var.image}"
        size      = var.worker_disk_size
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
      hostname = "${var.clustername}-worker"
      domain   = var.domain
      ssh_user = var.ssh_user
    })
    network_data = local.network_data
  }
}

resource "rancher2_cluster_v2" "cluster" {
  name               = var.clustername
  kubernetes_version = var.kubernetes_version

  rke_config {
    machine_pools {
      name                         = "control-plane"
      cloud_credential_secret_name = rancher2_cloud_credential.harvester.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = var.control_plane_count

      machine_config {
        kind = rancher2_machine_config_v2.control_plane.kind
        name = rancher2_machine_config_v2.control_plane.name
      }
    }

    machine_pools {
      name                         = "worker"
      cloud_credential_secret_name = rancher2_cloud_credential.harvester.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = var.worker_count

      machine_config {
        kind = rancher2_machine_config_v2.worker.kind
        name = rancher2_machine_config_v2.worker.name
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

    chart_values = yamlencode({
      harvester-cloud-provider = {
        global = {
          cattle = {
            clusterName = var.clustername
          }
        }
        cloudConfigPath = "/var/lib/rancher/rke2/etc/config-files/cloud-provider-config"
        kube-vip = {
          tolerations = [
            {
              effect   = "NoSchedule"
              key      = "node-role.kubernetes.io/control-plane"
              operator = "Exists"
            },
            {
              effect   = "NoExecute"
              key      = "node-role.kubernetes.io/etcd"
              operator = "Exists"
            },
            {
              effect   = "NoExecute"
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            }
          ]
        }
      }
    })
  }
}
