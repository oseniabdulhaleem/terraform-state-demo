variable "project_id" {
  description = "Your GCP Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone for compute resources"
  type        = string
  default     = "us-central1-a"
}