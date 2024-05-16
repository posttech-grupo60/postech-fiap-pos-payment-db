# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
   required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = ">= 0.13"
  backend "remote" {
    organization = "PosTechFIAPGrupo60Payment"
    workspaces {
      name = "postech-fiap-pos-payment-db"
    }
  }
}
provider "mongodbatlas" {
  public_key = var.apikey_public
  private_key  = var.apikey_private
}
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.org_id
  name = var.project_name
}

# Create a Database User
resource "mongodbatlas_database_user" "db-user" {
  username = "fiap-pos"
  password = "MpQc5Hhd9JTPTKjG"
  project_id = mongodbatlas_project.atlas-project.id
  auth_database_name = "fiap-pos"
  roles {
    role_name     = "readWrite"
    database_name = "${var.project_name}-db"
  }
}

resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  cidr_block = "0.0.0.0/0"
}

resource "mongodbatlas_cluster" "atlas-cluster" {
  project_id   = mongodbatlas_project.atlas-project.id
  name         = "${var.project_name}-cluster"
  cluster_type = "REPLICASET"
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = "US_EAST_1"
  provider_instance_size_name = "M0"
}

# Outputs to Display
output "atlas_cluster_connection_string" { value = mongodbatlas_cluster.atlas-cluster.connection_strings.0.standard_srv }
output "ip_access_list"    { value = mongodbatlas_project_ip_access_list.ip.ip_address }
output "project_name"      { value = mongodbatlas_project.atlas-project.name }
output "username"          { value = mongodbatlas_database_user.db-user.username } 
output "user_password"     { 
  sensitive = true
  value = mongodbatlas_database_user.db-user.password 
  }