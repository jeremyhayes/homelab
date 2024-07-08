terraform {
  backend "local" {
    path = "/opt/apps/terraform/terraform.tfstate"
  }
}

data "authentik_flow" "implicit_consent" {
  slug = "default-provider-authorization-implicit-consent"
}

# define forward auth proxy applications
locals {
  forward_auth_apps = tomap({
    pihole1    = tomap({
      slug  = "pihole1"
      name  = "Pi-Hole 1"
      icon  = "pihole.png"
    })
    pihole2    = tomap({
      slug  = "pihole2"
      name  = "Pi-Hole 2"
      icon  = "pihole.png"
    })
    pihole3    = tomap({
      slug  = "pihole3"
      name  = "Pi-Hole 3"
      icon  = "pihole.png"
    })
    visualizer = tomap({
      slug  = "visualizer"
      name  = "Swarm Visualizer"
      icon  = "docker-swarm.png"
    })
    whoami     = tomap({
      slug  = "whoami"
      name  = "WhoAmI"
      icon  = null
    })
  })
}

# create an application with associated provider
resource "authentik_provider_proxy" "forward_auth_app_proxy" {
  for_each = local.forward_auth_apps

  name                  = format("Provider for %s", each.value.name)
  external_host         = format("https://%s.lab.omglolwtfbbq.com", each.key)
  mode                  = "forward_single"
  access_token_validity = "hours=24"
  authorization_flow    = data.authentik_flow.implicit_consent.id
}

resource "authentik_application" "forward_auth_app" {
  for_each = authentik_provider_proxy.forward_auth_app_proxy

  slug              = each.key
  name              = local.forward_auth_apps[each.key].name
  protocol_provider = each.value.id

  meta_icon         = local.forward_auth_apps[each.key].icon != null ? (
      format("application-icons/%s", local.forward_auth_apps[each.key].icon)
    ) : (
      null
    )
}

# associate application proxies with embedded outpost
import {
  to = authentik_outpost.embedded
  id = "cd8308c7-955b-4ae6-bbc5-ab712ce70479"
}

resource "authentik_outpost" "embedded" {
  name               = "authentik Embedded Outpost"
  protocol_providers = [
    for k, v in authentik_provider_proxy.forward_auth_app_proxy : v.id
  ]
}

data "authentik_certificate_key_pair" "self_signed" {
  name              = "authentik Self-signed Certificate"
}

data "authentik_scope_mapping" "oauth2_scope_email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

data "authentik_scope_mapping" "oauth2_scope_openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_scope_mapping" "oauth2_scope_profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

# define oauth2 applications
locals {
  oauth2_apps = {
    grafana = {
      name          = "Grafana"
      client_id     = "Ix5MhtsNuENrzpqqPGBlIunfQpzcFdSGR1eyHB1r"
      redirect_uris = [
        "https://grafana.lab.omglolwtfbbq.com/login/generic_oauth"
      ]
      icon          = "grafana.svg"
      launch_url    = "https://grafana.lab.omglolwtfbbq.com/login/generic_oauth"
    }
  }
}

# create oauth2 applications with associated provider
resource "authentik_provider_oauth2" "oauth2_app_provider" {
  for_each = local.oauth2_apps

  name                  = format("Provider for %s", each.value.name)
  authorization_flow    = data.authentik_flow.implicit_consent.id
  client_id             = each.value.client_id
  redirect_uris         = each.value.redirect_uris
  sub_mode              = "user_username"
  signing_key           = data.authentik_certificate_key_pair.self_signed.id
  access_token_validity = "minutes=5"
  property_mappings     = [
    data.authentik_scope_mapping.oauth2_scope_openid.id,
    data.authentik_scope_mapping.oauth2_scope_email.id,
    data.authentik_scope_mapping.oauth2_scope_profile.id,
  ]
}

resource "authentik_application" "oauth2_app" {
  for_each = authentik_provider_oauth2.oauth2_app_provider

  slug              = each.key
  name              = local.oauth2_apps[each.key].name
  protocol_provider = each.value.id

  meta_icon         = local.oauth2_apps[each.key].icon != null ? (
      format("application-icons/%s", local.oauth2_apps[each.key].icon)
    ) : (
      null
    )
  meta_launch_url   = local.oauth2_apps[each.key].launch_url
}
