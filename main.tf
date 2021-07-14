###############
## Providers ##
###############
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.66.1"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
  required_version = ">= 0.14"
}

# Configure the Google provider.
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

###########################
## Project Configuration ##
###########################

# Enable required services on the project
resource "google_project_service" "service" {
  project = var.project_id

  for_each = toset(var.project_services)
  service  = each.key

  # Do not disable the service on destroy. This may be a shared
  # project, and we might not "own" the services we enable.
  disable_on_destroy = false
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

data "google_service_account" "default" {
  account_id = var.service_account_id
}

######################
## VM Configuration ##
######################

resource "google_compute_instance_template" "tpl" {
  labels       = var.labels
  name         = var.template_name
  machine_type = var.machine_type
  project      = var.project_id
  region       = var.region
  tags         = var.tags

  disk {
    source_image = var.instance_base_image
    auto_delete  = true
    mode         = "READ_WRITE"
    disk_size_gb = 100
    boot         = true
  }

  can_ip_forward = true

  network_interface {
    network = "default"
    access_config  {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.nginx.rendered
}

resource "google_compute_instance_from_template" "web" {
  count = var.node_count
  name  = format("web%02d", count.index + 1)
  zone  = var.zones[count.index]

  source_instance_template = google_compute_instance_template.tpl.id

  can_ip_forward = false
  labels = {
    "application" = "webserver",
    "environment" = "test",
  }

  tags = [
    "allow-ssh",
    "http-server",
    "load-balanced-backend",
  ]
}

resource "google_compute_instance_group" "web_group" {
  count     = var.node_count
  name      = format("web-group-%s", var.zones[count.index])
  zone      = var.zones[count.index]

  instances = [
    google_compute_instance_from_template.web[count.index].self_link
  ]

  named_port {
    name = "http"
    port = "80"
  }

  lifecycle {
    create_before_destroy = false
  }
}


################################
## Web Application Setup Info ##
################################

data "template_file" "nginx" {
  template = file("./template/install_nginx.tpl")
  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}

#############
## Outputs ##
#############

output "vm_internal_IPs" {
  value = google_compute_instance_from_template.web.*.network_interface.0.network_ip
}
output "External_HTTP_URL_IP" {
  value = format("http://%s/", google_compute_forwarding_rule.external.ip_address)
}
output "External_HTTP_URL_Domain" {
  value = format("http://%s/", trim(var.domain, "."))
}
