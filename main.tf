terraform {
  required_version = ">= 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate a random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# ==============================================================================
# STORAGE BUCKET - Simple resource to demonstrate state tracking
# ==============================================================================
resource "google_storage_bucket" "demo_bucket" {
  name          = "demo-state-bucket-${random_id.suffix.hex}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    environment = "demo"
    purpose     = "state-teaching"
  }
}

# ==============================================================================
# DATABASE WITH PASSWORD - Shows sensitive data in state
# ==============================================================================

# Generate a random password for the database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Cloud SQL Instance
resource "google_sql_database_instance" "demo_instance" {
  name             = "demo-db-instance-${random_id.suffix.hex}"
  database_version = "MYSQL_8_0"
  region           = var.region

  # Use smallest tier for demo purposes
  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all-for-demo"
        value = "0.0.0.0/0"
      }
    }
  }

  deletion_protection = false
}

# Database
resource "google_sql_database" "demo_db" {
  name     = "demo_database"
  instance = google_sql_database_instance.demo_instance.name
}

# Database user with password (THIS WILL BE IN STATE IN PLAIN TEXT!)
resource "google_sql_user" "demo_user" {
  name     = "demo_admin"
  instance = google_sql_database_instance.demo_instance.name
  password = random_password.db_password.result
}

# ==============================================================================
# COMPUTE INSTANCE WITH SSH KEY - Shows private key in state
# ==============================================================================

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Compute Engine Instance
resource "google_compute_instance" "demo_vm" {
  name         = "demo-vm-${random_id.suffix.hex}"
  machine_type = "e2-micro"
  zone         = var.zone

  tags = ["demo", "state-teaching"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  # SSH key in metadata (private key will be in state!)
  metadata = {
    ssh-keys = "demo-user:${tls_private_key.ssh_key.public_key_openssh}"
    demo     = "This instance demonstrates state management"
  }

  # Startup script
  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Demo VM for Terraform State Teaching" > /tmp/demo.txt
    echo "This was created by Terraform" >> /tmp/demo.txt
    apt-get update
  EOF
}

# ==============================================================================
# SECRET MANAGER - Shows secret values in state
# ==============================================================================

# Generate a random secret value
resource "random_password" "secret_value" {
  length  = 32
  special = true
}

# Secret Manager Secret
resource "google_secret_manager_secret" "app_secret" {
  secret_id = "app-secret-${random_id.suffix.hex}"

  replication {
    auto {}
  }

  labels = {
    demo = "state-teaching"
  }
}

# Secret version with actual secret data (THIS WILL BE IN STATE!)
resource "google_secret_manager_secret_version" "app_secret_version" {
  secret      = google_secret_manager_secret.app_secret.id
  secret_data = random_password.secret_value.result
}