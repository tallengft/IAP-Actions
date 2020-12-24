module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = local.project
  name                       = "private-gke"
  region                     = local.region
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-c"]
  network                    = google_compute_network.main.name
  subnetwork                 = google_compute_subnetwork.main.name
  ip_range_pods              = google_compute_subnetwork.main.secondary_ip_range[0].range_name
  ip_range_services          = google_compute_subnetwork.main.secondary_ip_range[1].range_name
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  network_policy             = true
  enable_private_endpoint    = true
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "172.8.0.0/28"

  node_pools = [
    {
      name              = "pool-01"
      min_count         = 1
      max_count         = 1
      local_ssd_count   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      image_type        = "COS"
      auto_repair       = true
      auto_upgrade      = true
      preemptible       = false
      max_pods_per_node = 12
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  master_authorized_networks = [
    {
      cidr_block   = google_compute_subnetwork.main.ip_cidr_range
      display_name = "VPC"
    },
  ]
}