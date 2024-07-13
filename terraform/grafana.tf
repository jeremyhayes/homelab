resource "grafana_data_source" "prometheus" {
  name       = "Prometheus"
  type       = "prometheus"
  url        = "http://prometheus:9090"
  is_default = true

  json_data_encoded = jsonencode({
    manageAlerts = true
  })
}

resource "grafana_data_source" "loki" {
  name       = "Loki"
  type       = "loki"
  url        = "http://loki:3100"
  is_default = false

  json_data_encoded = jsonencode({
    manageAlerts = true
  })
}
