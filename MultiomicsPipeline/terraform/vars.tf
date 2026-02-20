variable "project_id" {
  description = "The ID of the GCP project where resources will be created"
  type        = string
}

variable "region" {
  description = "The region for the resources (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "bucket_location" {
  description = "The GCS bucket location (e.g., US, EU, or a specific region)"
  type        = string
  default     = "US"
}

variable "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic for omics file notifications"
  type        = string
  default     = "omics-file-uploads"
}

variable "labels" {
  description = "A map of labels to apply to the resources"
  type        = map(string)
  default     = {
    pipeline = "multiomics"
    managed_by = "terraform"
  }
}

variable "repository_id" {
  description = "The name of the Artifact Registry repository"
  type        = string
  default     = "omics-images"
}

variable "image_name" {
  description = "The name of the image to build"
  type        = string
  default     = "omics-processor"
}

variable "google_storage_project_service_account" {
  description = "The service account email to use for GCS permissions. If null, the project's default GCS service account will be used."
  type        = string
  default     = null
}