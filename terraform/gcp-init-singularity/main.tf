provider "google" {
  project = var.project_id
  region  = var.region
}



# Local Variables for Template Substitution
locals {
  cloudbuild_yaml = templatefile("${path.module}/cloudbuild.yaml.tpl", {
    bucket_name     = var.bucket_name
    state_prefix    = var.state_prefix
    terraform_subdir = var.terraform_subdir
  })
}

# Create a Cloud Storage Bucket for Terraform State
resource "google_storage_bucket" "terraform_state" {
  name                        = var.bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

# Create a Service Account for Terraform Execution
resource "google_service_account" "terraform_sa" {
  account_id   = var.service_account_name
  display_name = "Terraform Cloud Build Service Account"
}

# Assign IAM Roles to the Service Account
resource "google_project_iam_binding" "terraform_roles" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}"
  ]
}

resource "google_project_iam_binding" "compute_admin_role" {
  project = var.project_id
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}"
  ]
}

resource "google_project_iam_binding" "iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.terraform_sa.email}"
  ]
}

# Output Cloud Build YAML
resource "local_file" "cloudbuild_yaml" {
  content  = local.cloudbuild_yaml
  filename = "${path.module}/cloudbuild.yaml"
}

# Outputs
output "cloudbuild_yaml_path" {
  value = local_file.cloudbuild_yaml.filename
  description = "Path to the generated cloudbuild.yaml file"
}