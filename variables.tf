variable "project_id" {
  description = "The project ID for Google Cloud resources"
  type        = string
  default     = "flask-server-deployment" # Adjust as needed
}

variable "region" {
  description = "The region for Google Cloud resources"
  type        = string
  default     = "asia-south2" # Adjust as needed
}

variable "app_region" {
  description = "The region for Google Cloud app engine"
  type        = string
  default     = "asia-south1" # Adjust as needed
}

variable "db_password" {
  description = "The password for the Cloud SQL database user"
  type        = string
  sensitive   = true
  default = "root"
}

variable "app_version_id" {
  description = "App Engine Version ID"
  type        = string
  default     = "v1"
}
