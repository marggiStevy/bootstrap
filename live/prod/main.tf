locals {
  subnet_01     = "${var.network_name}-sub-01"
  prefix        = "sm"
  cloudbuild_sa = format("%s@cloudbuild.gserviceaccount.com", module.service-project.project_number, )

}

/******************************************
  Folder Creation
 *****************************************/

module "folders" {
  source  = "terraform-google-modules/folders/google"
  version = "~> 4.0"

  parent    = var.parent
  names     = ["smarggi"]
  set_roles = true
  all_folder_admins = [
    "group:gcp-devops@davidson.group",
    "user:stevy.marggi@davidson.group"
  ]
}

/******************************************
  Folder IAM Binding for CICD
 *****************************************/

resource "google_folder_iam_member" "cicd-folder-prod" {
  for_each = toset(var.cloudbuild_roles)

  folder = module.folders.id
  role   = each.value
  member = "serviceAccount:${local.cloudbuild_sa}"
}

/******************************************
  Host Project Creation
 *****************************************/

module "host-project" {
  source                         = "terraform-google-modules/project-factory/google"
  version                        = "~> 14.4"
  random_project_id              = true
  name                           = "${local.prefix}-${var.host_project_name}"
  org_id                         = var.organization_id
  folder_id                      = module.folders.id
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
  default_network_tier           = var.default_network_tier

  activate_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com"
  ]

}

/******************************************
  Budget Project Creation
 *****************************************/

module "budget" {
source          = "terraform-google-modules/project-factory/google//modules/budget"
billing_account = var.billing_account
projects        = ["${module.host-project.project_id}", "${module.service-project.project_id}"]
display_name    = "${local.prefix}-${module.folders.name}"
amount          = "20"
alert_spent_percents = [
0.5,
0.7,
1
]
}

/******************************************
  Network Creation
 *****************************************/
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.0"

  project_id                             = module.host-project.project_id
  network_name                           = "${local.prefix}-${var.network_name}"
  delete_default_internet_gateway_routes = false

  subnets = [
    {
      subnet_name           = local.subnet_01
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    (local.subnet_01) = [
      {
        range_name    = "${local.subnet_01}-01"
        ip_cidr_range = "192.168.64.0/24"
      },
      {
        range_name    = "${local.subnet_01}-02"
        ip_cidr_range = "192.168.65.0/24"
      },
    ]
  }
}

resource "google_compute_firewall" "iap_ssh_rule" {
  project = module.host-project.project_id
  name    = "fwr-ing-iap-ssh"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] // Plages IP pour IAP
  target_tags   = ["iap-ssh"]         // Cible les instances avec le tag iap-ssh
}

module "cloud-router-dev-r1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "6.0.2"

  project = module.host-project.project_id
  name    = var.router_name
  network = module.vpc.network_self_link
  region  = var.region

  nats = [{
    name = var.nat_name
  }]
}

/******************************************
  Service Project Creation
 *****************************************/
module "service-project" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.4"

  name              = "${local.prefix}-${var.service_project_name}"
  random_project_id = true

  org_id          = var.organization_id
  folder_id       = module.folders.id
  billing_account = var.billing_account

  shared_vpc         = module.host-project.project_id
  shared_vpc_subnets = module.vpc.subnets_self_links

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  disable_services_on_destroy = false
}

/******************************************
  Enabling OS Login
 *****************************************/

resource "google_compute_project_metadata" "host_project_metadata" {
  project = module.host-project.project_id
  metadata = {
    enable-oslogin          = "TRUE"
    enable-osconfig         = "TRUE"
    enable-guest-attributes = "TRUE"
  }
}

resource "google_compute_project_metadata" "service_project_metadata" {
  project = module.service-project.project_id
  metadata = {
    enable-oslogin          = "TRUE"
    enable-osconfig         = "TRUE"
    enable-guest-attributes = "TRUE"
  }
}

/******************************************
  CICD ORG IAM Binding
 *****************************************/

resource "google_organization_iam_member" "binding" {
  for_each = toset(var.cloudbuild_roles_org_billing)

  org_id = var.organization_id
  role   = each.value
  member = "serviceAccount:${local.cloudbuild_sa}"
}
