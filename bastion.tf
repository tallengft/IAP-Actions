##
## Important: the following resources are implemented as a temporary measure until VPC connectivity to on-premises is achieved.
##

locals {
  bastion_name = format("%s-bastion", "iap-test")
  bastion_zone = format("%s-a", local.region)
}

data "template_file" "startup_script" {
  count    = var.enable_bastion ? 1 : 0
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

module "bastion" {
  count          = var.enable_bastion ? 1 : 0
  source         = "terraform-google-modules/bastion-host/google"
  version        = "~> 2.0"
  network        = google_compute_network.main.self_link
  subnet         = google_compute_subnetwork.main.self_link
  project        = local.project
  host_project   = local.project
  name           = "hardened-gke-test-bastion"
  zone           = local.region
  image_project  = "debian-cloud"
  image_family   = "debian-9"
  machine_type   = "g1-small"
  startup_script = data.template_file.startup_script[0].rendered
  members        = [
    "user:tyleruk2000@gmail.com",
  ]
  shielded_vm    = "false"
  service_account_name = "hardened-gke-test-bastion"
  fw_name_allow_ssh_from_iap = "hardened-gke-test-bastion"
}

module "bastion-nat" {
  count         = var.enable_bastion ? 1 : 0
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = local.project
  region        = ocal.region
  router        = "hardened-gke-test-bastion-nat"
  network       = google_compute_network.main.self_link
  create_router = true
}