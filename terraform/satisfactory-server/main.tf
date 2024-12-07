# Initialize provider
provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "us-central1" # Update to your desired region
}

# Define Google Cloud Run service
resource "google_cloud_run_service" "satisfactory_server" {
  name     = "satisfactory-server"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "wolveix/satisfactory-server:latest"

        resources {
          # Define memory limits
          limits = {
            memory = "8Gi"
          }
          requests = {
            memory = "4Gi"
          }
        }

        env {
          name  = "MAXPLAYERS"
          value = "4"
        }
        env {
          name  = "PGID"
          value = "1000"
        }
        env {
          name  = "PUID"
          value = "1000"
        }
        env {
          name  = "ROOTLESS"
          value = "false"
        }
        env {
          name  = "STEAMBETA"
          value = "false"
        }

        # Port configuration for the container
        ports {
          name = "udp-port"
          container_port = 7777
          protocol       = "UDP"
        }
        ports {
          name = "tcp-port"
          container_port = 7777
          protocol       = "TCP"
        }

        # Mount volume
        volume_mounts {
          name       = "config-volume"
          mount_path = "/config"
        }
      }

      # Define the volume
      volumes {
        name = "config-volume"
        secret {
          secret_name = "satisfactory-config"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# IAM policy to allow unauthenticated access (optional)
resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.satisfactory_server.location
  project  = google_cloud_run_service.satisfactory_server.project
  service  = google_cloud_run_service.satisfactory_server.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

# Configure Cloud Run to use a GCP service account
resource "google_service_account" "cloud_run_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

# Bind service account to Cloud Run service
resource "google_cloud_run_service_iam_binding" "cloud_run_bind" {
  service  = google_cloud_run_service.satisfactory_server.name
  location = google_cloud_run_service.satisfactory_server.location
  role     = "roles/run.serviceAgent"

  members = [
    "serviceAccount:${google_service_account.cloud_run_account.email}"
  ]
}

# Optional: Create a Secret for Volume Mount (requires configuration of a GCP Secret Manager secret)
resource "google_secret_manager_secret" "satisfactory_config" {
  secret_id = "satisfactory-config"
}

resource "google_secret_manager_secret_version" "satisfactory_config_version" {
  secret = google_secret_manager_secret.satisfactory_config.id
  data   = base64encode(file("./satisfactory-server"))
}
