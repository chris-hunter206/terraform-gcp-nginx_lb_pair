###########################
## Network Configuration ##
###########################

locals {
  regions = [
    "us-west1",
  ]
}

data "google_compute_network" "default" {
  name = var.network
}

data "google_compute_subnetwork" "default" {
  name    = var.subnetwork
  project = var.project_id
  region  = var.region
}


# Define HTTP allow rule
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  source_tags = ["http-server"]
}

############################
## Internal Load Balancer ##
############################


# health check for backend service can only use 'health_check'
# and not legacy 'http_health_check'
resource "google_compute_health_check" "web_int" {
  name  = "http-int-health-check"
  http_health_check {
    port = 80
  }
}

# define backend service
resource "google_compute_region_backend_service" "web_int" {
  count    = length(var.zones)
  project  = var.project_id
  name     = format("web-backend-svc-%s", var.zones[count.index])
  region   = var.region

  load_balancing_scheme = "INTERNAL"

  health_checks = [
    google_compute_health_check.web_int.self_link,
  ]

  backend {
    group = google_compute_instance_group.web_group[count.index].id
    balancing_mode = "CONNECTION"
  }
}

# Forward internal traffic to the backend service
resource "google_compute_forwarding_rule" "web_int" {

  project               = var.project_id
  name                  = format("web-int-%s", var.region)
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  network_tier          = "PREMIUM"
  allow_global_access   = true
  subnetwork            = var.subnetwork

  backend_service = google_compute_region_backend_service.web_int[0].self_link
  ports           = [80]
}

############################
## External Load Balancer ##
############################

# Unlike the backend service, the frontend target pool, requires the legacy
# "http_health_check" and can't use "health_check", so we'll define that here.
# We'll need a seperate check for each zone in var.zones
resource "google_compute_http_health_check" "web" {
  count   = length(var.zones)
  project = var.project_id
  name    = format("web-health-internal-%s", var.zones[count.index])

  request_path        = "/"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# setup pool for the global region and define instance members from our VM
# instances, including the http_health_check above
resource "google_compute_target_pool" "global_region" {
  project = var.project_id
  name    = "global-region-pool"
  region  = local.regions.0

  instances = [
    "us-west1-a/web01",
    "us-west1-c/web02",
  ]

  health_checks = [
    google_compute_http_health_check.web.0.self_link,
  ]
}

# Forward external traffic to the target pool
resource "google_compute_forwarding_rule" "external" {
  project               = var.project_id
  name                  = "web-external"
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  network_tier          = "PREMIUM"

  target     = google_compute_target_pool.global_region.self_link
  port_range = "80"
}

