# Terraform State Demo - Quick Setup

A hands-on demo showing how Terraform state works and why it contains sensitive data in plain text.

---

## 🚀 Quick Setup (5 minutes)

### Option 1: Cloud Shell (Easiest - No Setup Needed!)
```bash
# Already authenticated in Cloud Shell!
git clone <YOUR_REPO_URL>
cd terraform-state-demo
```

### Option 2: Local Setup

**Prerequisites:**
- Terraform installed ([download here](https://developer.hashicorp.com/terraform/downloads))
- gcloud CLI installed ([download here](https://cloud.google.com/sdk/docs/install))

**Authenticate with GCP:**
```bash
# Login to GCP
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

**Get the code:**
```bash
git clone <YOUR_REPO_URL>
cd terraform-state-demo
```

---

## ⚙️ Configuration (1 minute)

**Edit `terraform.tfvars`:**
```hcl
project_id = "your-actual-project-id"  # Change this!
region     = "us-central1"
zone       = "us-central1-a"
```

**Enable required APIs:**
```bash
gcloud services enable compute.googleapis.com \
  sqladmin.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com
```

---

## 🎯 Run the Demo
```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create the infrastructure
terraform apply
# Type 'yes' when prompted
```

**⏱️ Wait time:** 5-7 minutes (SQL instance takes the longest)

---

## 🔍 View Passwords in State (KEY DEMO!)

After `terraform apply` completes:
```bash
# See the state file
cat terraform.tfstate

# Find database password (PLAIN TEXT!)
grep -A 2 "db_password" terraform.tfstate

# Find SSH private key (PLAIN TEXT!)
grep -A 5 "private_key_pem" terraform.tfstate

# Find secret value (PLAIN TEXT!)
grep -A 2 "secret_value" terraform.tfstate
```

**⚠️ THIS IS THE POINT:** Even though outputs say `<sensitive>`, the values are in plain text in the state file!

---

## 📝 Practice State Commands
```bash
# List all resources
terraform state list

# Show resource details
terraform state show random_password.db_password

# Pull state backup
terraform state pull > backup.json

# Move/rename resource
terraform state mv google_storage_bucket.demo_bucket google_storage_bucket.renamed

# Remove from state (doesn't delete resource)
terraform state rm google_secret_manager_secret.app_secret
```

---

## 🧹 Cleanup
```bash
# Destroy all resources
terraform destroy
# Type 'yes' when prompted
```

---

## 📚 What You'll Learn

✅ How Terraform state tracks resources  
✅ Why state files contain secrets in plain text  
✅ Essential state management commands  
✅ How to import existing resources  
✅ Why remote backends are critical for security  

---

## 🆘 Troubleshooting

**"Permission denied" error:**
```bash
gcloud auth application-default login
```

**"API not enabled" error:**
```bash
gcloud services enable <SERVICE_NAME>
```

**SQL instance taking too long:**
- Comment out the SQL resources in `main.tf` (lines 40-78)
- The demo works fine with just the bucket, VM, and secret

**"Project not set" error:**
```bash
gcloud config set project YOUR_PROJECT_ID
```

---

## 🎓 Key Takeaway

**State files contain ALL resource data in plain text, including passwords, SSH keys, and secrets.**

This is why:
- ❌ Never commit state to Git
- ✅ Always use remote backends with encryption
- ✅ Restrict state file access with IAM
- ✅ Treat state files like passwords

---