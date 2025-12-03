terraform {
  backend "local" {
    path = "/opt/apps/terraform/terraform.tfstate"
  }

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.10.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "4.21.0"
    }
  }
}

provider "authentik" {
  url   = "https://auth.lab.omglolwtfbbq.com"
  token = var.authentik_token
}

provider "grafana" {
  url  = "https://grafana.lab.omglolwtfbbq.com"
  auth = var.grafana_token
}
