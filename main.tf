provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable necessary APIs
resource "google_project_service" "vpc_access_api" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "sql_admin_api" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "app_engine_api" {
  project = var.project_id
  service = "appengine.googleapis.com"
}

resource "google_project_service" "cloud_build_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

# VPC Network
resource "google_compute_network" "vpc_network" {
  name = "appengine-vpc"
  auto_create_subnetworks = false
}

# Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

# Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  network                  = google_compute_network.vpc_network.id
  region                   = var.region
  private_ip_google_access = true # Enables access to Google APIs via private IP
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL Instance (MySQL)
resource "google_sql_database_instance" "mysql_instance" {
  name             = "newdb"
  database_version = "MYSQL_8_0" # MySQL version
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}

# Cloud SQL Database
resource "google_sql_database" "app_db" {
  name     = "flask_app_db"
  instance = google_sql_database_instance.mysql_instance.name
}

# Cloud SQL User
resource "google_sql_user" "app_user" {
  name     = "flask_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = var.db_password
}

resource "google_storage_bucket" "app_bucket" {
  name          = "flask_rishabh_test_1"
  location      = var.region
  force_destroy = false
  website {
    main_page_suffix = "welcome.html"
  }
}

# List all HTML files in the directory
locals {
  html_files = fileset("${path.module}/app/templates", "*.html")
}

# Loop through each HTML file and upload it to the bucket
resource "google_storage_bucket_object" "html_files" {
   for_each    = toset(local.html_files)
  name        = each.value
  bucket      = google_storage_bucket.app_bucket.name
  source      = "${path.module}/app/templates/${each.value}"
  content_type = "text/html"
}

# Set public access for objects in the bucket
resource "google_storage_bucket_iam_member" "all_users" {
  bucket = google_storage_bucket.app_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket" "app_files" {
  name     = "rishabh-app-files-test-1"
  location = var.region
}

resource "google_storage_bucket_object" "app_py" {
  name   = "app.py"
  bucket = google_storage_bucket.app_files.name
  source = "${path.module}/app/app.py"
}

resource "google_storage_bucket_object" "app_yaml" {
  name   = "app.yaml"
  bucket = google_storage_bucket.app_files.name
  source = "${path.module}/app/app.yaml"
}

resource "google_storage_bucket_iam_member" "all_users_server" {
  bucket = google_storage_bucket.app_files.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_app_engine_application" "default" {
  project     = var.project_id
  location_id = var.app_region # Replace with the region of your existing App Engine
}

# Define App Engine Flexible Environment deployment
resource "google_app_engine_standard_app_version" "app_version" {
  project    = var.project_id
  version_id = var.app_version_id
  service    = "default"
  runtime    = "python39"

  entrypoint {
    shell = "gunicorn -b :5000 app:app"
  }

  deployment {
    files {
      name = "flask_app"
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_files.name}/${google_storage_bucket_object.app_py.name}"
    }
    files {
      name = "flask_config"
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_files.name}/${google_storage_bucket_object.app_yaml.name}"
    }
  }
}