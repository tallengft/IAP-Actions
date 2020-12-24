module "iap_bastion" {
  source = "terraform-google-modules/bastion-host/google"

  project   = local.project
  zone      = local.zone
  network   = google_compute_network.main.self_link
  subnet    = google_compute_subnetwork.main.self_link
  members = [
    "user:tyleruk2000@gmail.com",
  ]
}