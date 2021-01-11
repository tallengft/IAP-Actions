##
## Important: the following resources are implemented as a temporary measure until VPC connectivity to on-premises is achieved.
##

locals {
  bastion_name = format("%s-bastion", "iap-test")
  bastion_zone = format("%s-a", local.region)
}

data "template_file" "startup_script" {
  count    = 1
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

module "bastion" {
  count          = 1
  source         = "terraform-google-modules/bastion-host/google"
  version        = "~> 2.0"
  network        = google_compute_network.main.self_link
  subnet         = google_compute_subnetwork.main.self_link
  project        = local.project
  host_project   = local.project
  name           = "bastion-vm"
  zone           = "us-central1-a"
  image_project  = "debian-cloud"
  image_family   = "debian-9"
  machine_type   = "g1-small"
  startup_script = data.template_file.startup_script[0].rendered
  members        = [
    "user:tyleruk2000@gmail.com",
  ]
  shielded_vm    = "false"
  service_account_name = "bastion-vm"
  fw_name_allow_ssh_from_iap = "bastion-vm"
}

module "bastion-nat" {
  count         = 1
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = local.project
  region        = local.region
  router        = "bastion-vm"
  network       = google_compute_network.main.self_link
  create_router = true
}