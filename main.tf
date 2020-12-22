locals {
  project   = ""
  region    = "us-central1"
  zone      = "us-central1-c"
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}

resource "google_compute_instance" "vm_instance" {
  name         = "single-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.iap_network.self_link
    subnetwork = google_compute_subnetwork.private_subet.self_link
  }
}

resource "google_compute_subnetwork" "private_subet" {
  name                          = "iap-subnetwork"
  ip_cidr_range                 = "10.2.0.0/16"
  region                        = local.region
  network                       = google_compute_network.iap_network.id
  private_ip_google_access      = true
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "iap_network" {
  name                    = "iap-network"
  auto_create_subnetworks = false
}

module "iap_bastion" {
  source = "terraform-google-modules/bastion-host/google"

  project   = local.project
  zone      = local.zone
  network   = google_compute_network.iap_network.self_link
  subnet    = google_compute_subnetwork.private_subet.self_link
  members = [
    "user:tyleruk2000@gmail.com",
  ]
}