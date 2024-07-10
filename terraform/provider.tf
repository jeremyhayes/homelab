terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
    }
    grafana = {
      source  = "grafana/grafana"
    }
  }
}

variable "authentik_token" {
  description = "API token for Authentik"
  type        = string
}

provider "authentik" {
  url   = "https://auth.lab.omglolwtfbbq.com"
  token = var.authentik_token
}

variable "grafana_token" {
  description = "Service account token for Grafana"
  type        = string
}

provider "grafana" {
  url  = "https://grafana.lab.omglolwtfbbq.com"
  auth = var.grafana_token
}
