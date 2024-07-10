terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
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
