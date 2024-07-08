terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
    }
  }
}

provider "authentik" {
  url   = "https://auth.lab.omglolwtfbbq.com"
  # token is supplied as env in wrapper script
}
