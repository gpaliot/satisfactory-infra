# Variables

variable "project_id" {}

variable "region" {
  default = "eu-west-4"
}

variable "state_prefix" {
  default = "terraform/state"
}
variable "service_account_name" {
  default = "terraform-cloudbuild-sa"
}
variable "terraform_subdir" {
  default = "terraform/satisfactory-server"
}
variable "github_owner" {}
variable "github_repo" {}