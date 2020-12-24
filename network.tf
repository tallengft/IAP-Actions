resource "google_compute_network" "main" {
  project                 = local.project
  name                    = "private-gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  project       = local.project
  name          = "private-gke-main"
  ip_cidr_range = "10.0.0.0/17"
  region        = local.region
  network       = google_compute_network.main.self_link

  secondary_ip_range {
    range_name    = "private-gke-pods"
    ip_cidr_range = "192.168.0.0/18"
  }

  secondary_ip_range {
    range_name    = "private-gke-test-services"
    ip_cidr_range = "192.168.64.0/18"
  }
}