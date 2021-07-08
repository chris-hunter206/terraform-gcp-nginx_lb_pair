variable "credentials_file" {
  description = "Json file containing service account credentials Terraform will use"
  type = string
}
variable "domain" {
  description = "Top level DNS Hostname where test application should respond from"
  type = string
}
variable "instance_base_image" {
  description = "VM Machine image used to generate google compute instances"
  type = string
}
variable "labels" {
  description = "VM instance labels"
  type = map
}
variable "managed_zone_name" {
  description = "data resource name for google_dns_managed_zone"
  type = string
}
variable "node_names" {
  description = "VM instance node names"
  type = list(string)
}
variable "node_count" {
  description = "Number of VM instances in group"
  type = number
}
variable "machine_type" {
  description = "GCP Hardware platform to be used for VM instances"
  type = string
}
variable "project_id" {
  description = "GCP project id"
  type = string
}
variable "project_services" {
  description = "List of services that will be needed for the project"
  type = list(string)
}
variable "region" {
  description = "GCP Global Region"
  type = string
}
variable "service_account_email" {
  description = "Email address of the GCP terraform service account"
  type = string
}
variable "service_account_id" {
  description = "Text name of the GCP terraform service account"
  type = string
}
variable "tags" {
  description = "Tags for VM instances"
  type = list(string)
}
variable "template_name" {
  description = "Name of the VM instance template"
  type = string
}
variable "zones" {
  description = "GCP zones within Global Region"
  type = list(string)
}
