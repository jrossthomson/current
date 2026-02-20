# 1. Create the Pub/Sub Topic
resource "google_pubsub_topic" "omics_updates" {
  name = "omics-file-uploads"

  depends_on = [google_project_service.eventarc]
}

# 2. Get the GCS Service Account for your project
# This is a special internal account used by GCS to perform background tasks
data "google_storage_project_service_account" "gcs_account" {}

# 3. Grant GCS permission to publish to the Pub/Sub topic
resource "google_pubsub_topic_iam_binding" "gcs_publisher_binding" {
  topic   = google_pubsub_topic.omics_updates.name
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

# 4. Create the GCS Bucket
resource "google_storage_bucket" "input_bucket" {
  name     = "my-multiomic-input-data-${var.project_id}" # Must be globally unique
  location = "US"
  uniform_bucket_level_access = true
  force_destroy               = true # Allows deleting bucket even if it contains objects
  labels = var.labels
}

resource "google_storage_bucket" "scripts_bucket" {
  name          = "my-multiomic-scripts-${var.project_id}"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
  labels        = var.labels
}

resource "google_storage_bucket" "work_bucket" {
  name          = "my-multiomic-work-${var.project_id}"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
  labels        = var.labels
}

# Upload the pipeline script to the scripts bucket
resource "google_storage_bucket_object" "pipeline_script" {
  name   = "main.nf"
  bucket = google_storage_bucket.scripts_bucket.name
  source = "${path.module}/../cloud-run/your-pipeline/main.nf"
}



resource "local_file" "nextflow_config" {
  content = <<EOF
profiles {
    google_batch {
        process.executor = 'google-batch'
        google.project = "${var.project_id}"
        google.location = "${var.region}"
    }
}
EOF
  filename = "${path.module}/../cloud-run/nextflow.config"
}

# 5. Create the GCS Notification
resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.input_bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.omics_updates.id
  event_types    = ["OBJECT_FINALIZE"] # Only trigger when a new file is uploaded/created
  
  # Ensure the IAM binding is created before the notification
  depends_on = [google_pubsub_topic_iam_binding.gcs_publisher_binding]
}

# 6. Deploy the Cloud Run Service
resource "google_cloud_run_v2_service" "omics_processor" {
  name     = "omics-processor-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY" # Only allow traffic from internal sources (like Pub/Sub)
  labels   = var.labels
  deletion_protection = false

  depends_on = [null_resource.build_image]

  template {
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
      "client.knative.dev/user-image"  = local.image_path
      "terraform.build-id"             = null_resource.build_image.id
    }
    containers {
      image = local.image_path
      env {
        name  = "SCRIPTS_BUCKET"
        value = google_storage_bucket.scripts_bucket.name
      }
      env {
        name  = "WORK_BUCKET"
        value = google_storage_bucket.work_bucket.name
      }
      resources {
        limits = {
          cpu    = "2"
          memory = "4Gi" # Genomic processing often needs high memory
        }
      }
    }
  }
}

# 7. Create a Service Account for the Trigger
resource "google_service_account" "trigger_sa" {
  account_id   = "omics-trigger-sa"
  display_name = "Omics Trigger Service Account"
}

# 8. Grant the Trigger SA permission to call Cloud Run
resource "google_cloud_run_v2_service_iam_member" "run_invoker" {
  name     = google_cloud_run_v2_service.omics_processor.name
  location = google_cloud_run_v2_service.omics_processor.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.trigger_sa.email}"
}

# 9. Create the Eventarc Trigger (Connects Pub/Sub -> Cloud Run)
resource "google_eventarc_trigger" "trigger" {
  name     = "omics-file-trigger"
  location = var.region
  
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.omics_processor.name
      region  = var.region
    }
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.omics_updates.id
    }
  }

  service_account = google_service_account.trigger_sa.email
}

# A. Create the Artifact Registry to store the image
resource "google_artifact_registry_repository" "omics_repo" {
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
}

# B. Build the image using Cloud Build via local-exec
resource "null_resource" "build_image" {
  # This triggers the build whenever the Dockerfile or related files change
  triggers = {
    dir_sha1 = sha1(join("", [
      for f in sort(concat(
        tolist(fileset("${path.module}/../cloud-run", "*")),
        tolist(fileset("${path.module}/../cloud-run", "your-pipeline/*"))
      )) : filesha1("${path.module}/../cloud-run/${f}")
    ]))
    # Force rebuild when nextflow config content changes
    nextflow_config_hash = sha1(local_file.nextflow_config.content)
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud builds submit ../cloud-run \
        --tag ${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/${var.image_name}:latest \
        --project ${var.project_id}
    EOT
  }

  depends_on = [
    google_artifact_registry_repository.omics_repo,
    local_file.nextflow_config
  ]
}

# C. Define a Local for the image path (The "Return" value)
locals {
  image_path = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}/${var.image_name}:latest"
}