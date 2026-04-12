variable "pfsense_password" {
  description = "The password for the pfSense admin user"
  type        = string
  sensitive   = true
}