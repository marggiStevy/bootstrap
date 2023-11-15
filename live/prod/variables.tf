/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "organization_id" {
  description = "The organization id for the associated services"
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
}

variable "host_project_name" {
  description = "Name for Shared VPC host project"
  default     = "shared-vpc-host"
}

variable "service_project_name" {
  description = "Name for Shared VPC service project"
  default     = "shared-vpc-service"
}

variable "network_name" {
  description = "Name for Shared VPC network"
  default     = "shared-vpc"
}

variable "default_network_tier" {
  description = "Default Network Service Tier for resources created in this project. If unset, the value will not be modified. See https://cloud.google.com/network-tiers/docs/using-network-service-tiers and https://cloud.google.com/network-tiers."
  type        = string
  default     = ""
}

variable "region" {
  description = "The default region"
  default     = "northamerica-northeast1"
}

variable "parent" {
  type        = string
  description = "The resource name of the parent Folder or Organization. Must be of the form folders/folder_id or organizations/org_id"
}

variable "names" {
  type        = list(string)
  description = "Folder names."
  default     = []
}

variable "set_roles" {
  type        = bool
  description = "Enable setting roles via the folder admin variables."
  default     = false
}

variable "per_folder_admins" {
  type = map(object({
    members = list(string)
    roles   = optional(list(string))
  }))
  description = "IAM-style roles per members per folder who will get extended permissions. If roles are not provided for a folder/member combination, the list provided as `folder_admin_roles` will be applied as default."
  default     = {}
}

variable "all_folder_admins" {
  type        = list(string)
  description = "List of IAM-style members that will get the extended permissions across all the folders."
  default     = []
}

variable "prefix" {
  type        = string
  description = "Optional prefix to enforce uniqueness of folder names."
  default     = ""
}

variable "folder_admin_roles" {
  type        = list(string)
  description = "List of roles that will be applied to a folder if roles are not explictly specified in per_folder_admins"

  default = [
    "roles/owner",
    "roles/resourcemanager.folderViewer",
    "roles/resourcemanager.projectCreator",
    "roles/compute.networkAdmin",
  ]
}

variable "router_name" {
  type = string
}

variable "nat_name" {
  type = string
}

variable "cloudbuild_roles" {
  type = list(string)
}

variable "cloudbuild_roles_org_billing" {
  type = list(string)
}
