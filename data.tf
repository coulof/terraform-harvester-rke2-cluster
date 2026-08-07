data "rancher2_cluster_v2" "harvester" {
  name            = var.harvester_cluster_name
  fleet_namespace = var.harvester_fleet_namespace
}
