output "bucket_name" {
  description = "Name of the created storage bucket"
  value       = google_storage_bucket.demo_bucket.name
}

output "database_connection" {
  description = "Database instance connection name"
  value       = google_sql_database_instance.demo_instance.connection_name
}

output "database_ip" {
  description = "Database instance IP address"
  value       = google_sql_database_instance.demo_instance.ip_address
}

# Even though marked as sensitive, this is still visible in state file!
output "db_password" {
  description = "Database root password (sensitive in output, but NOT in state!)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.demo_vm.name
}

output "instance_external_ip" {
  description = "External IP of the compute instance"
  value       = google_compute_instance.demo_vm.network_interface[0].access_config[0].nat_ip
}

# SSH private key marked sensitive, but still in state!
output "ssh_private_key" {
  description = "SSH private key (sensitive in output, but NOT in state!)"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "SSH public key"
  value       = tls_private_key.ssh_key.public_key_openssh
}

output "secret_id" {
  description = "Secret Manager secret ID"
  value       = google_secret_manager_secret.app_secret.secret_id
}

# Secret value marked sensitive, but still in state!
output "secret_value" {
  description = "Secret Manager secret value (sensitive in output, but NOT in state!)"
  value       = random_password.secret_value.result
  sensitive   = true
}

# Teaching note output
output "security_warning" {
  description = "Important security reminder"
  value       = "⚠️ CRITICAL: All sensitive values above are stored in PLAIN TEXT in terraform.tfstate file!"
}