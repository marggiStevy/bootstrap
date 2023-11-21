organization_id      = "387682424329"
billing_account      = "013C1B-BFCBA7-95CD8C"
host_project_name    = "dav-xpn-prj"
service_project_name = "dav-svc-prj"
network_name         = "net-vpc"
region               = "us-central1"
parent               = "folders/8535733468"
router_name          = "rtr-nat-nane1"
nat_name             = "nat-gw-nane1"

folder_admin_roles = [
  "roles/owner",
  "roles/resourcemanager.folderViewer",
  "roles/resourcemanager.projectCreator",
  "roles/compute.networkAdmin",
  "roles/serviceusage.serviceUsageConsumer",
  "roles/cloudsql.admin",
  "roles/run.admin",
  "roles/resourcemanager.projectIamAdmin",
]

cloudbuild_roles = [
  "roles/owner",
  "roles/resourcemanager.folderViewer",
  "roles/resourcemanager.projectCreator",
  "roles/compute.networkAdmin",
  "roles/serviceusage.serviceUsageConsumer",
]

cloudbuild_roles_org_billing = [
  "roles/billing.user",
  "roles/billing.costsManager"
]
