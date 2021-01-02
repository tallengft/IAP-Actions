locals {
  project   = "iap-test-9kx81"
  region    = "us-central1"
  zone      = "us-central1-c"
}

provider "google" {
  project = local.project
  region  = local.region
  zone    = local.zone
}