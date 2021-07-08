
data "google_dns_managed_zone" "dns-public" {
  name = var.managed_zone_name
}

resource "google_dns_record_set" "root" {
  managed_zone = var.managed_zone_name
  name         = var.domain
  project      = var.project_id
  ttl          = 300
  type         = "A"
  rrdatas      = [google_compute_forwarding_rule.external.ip_address]
}

resource "google_dns_record_set" "www" {
  managed_zone = var.managed_zone_name
  name         = format("www.%s", var.domain)
  project      = var.project_id
  ttl          = 300
  type         = "A"
  rrdatas      = [google_compute_forwarding_rule.external.ip_address]
}
