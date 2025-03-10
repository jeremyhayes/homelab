locals {
  # define forward auth proxy applications
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

  # define oauth2 applications
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
    paperless = {
      name          = "Paperless"
      client_id     = "5wOSg36P4TaTWP6lt0NO2s9Ww3v3LBf9kxEf51c9"
      redirect_uris = [
        "https://paperless.lab.omglolwtfbbq.com/accounts/oidc/authentik/login/callback/"
      ]
      icon          = "paperless.png"
      launch_url    = null
    }
    synology = {
      name          = "Synology"
      client_id     = "JyTaYfuAVj0F8kM8FwlrcrUSeiVQ2KwLy9Ehzc7D"
      redirect_uris = [
        "https://synology.lab.omglolwtfbbq.com/#/signin"
      ]
      icon          = "synology-dsm.png"
      launch_url    = null
    }
  }
}

data "authentik_flow" "implicit_consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

# create an application with associated provider
resource "authentik_provider_proxy" "forward_auth_app_proxy" {
  for_each = local.forward_auth_apps

  name                  = format("Provider for %s", each.value.name)
  external_host         = format("https://%s.lab.omglolwtfbbq.com", each.key)
  mode                  = "forward_single"
  access_token_validity = "hours=24"
  authorization_flow    = data.authentik_flow.implicit_consent.id
  invalidation_flow     = data.authentik_flow.default_invalidation_flow.id
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
  name = "authentik Self-signed Certificate"
}

data "authentik_property_mapping_provider_scope" "oauth2_scope_email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

data "authentik_property_mapping_provider_scope" "oauth2_scope_openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "oauth2_scope_profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

# create oauth2 applications with associated provider
resource "authentik_provider_oauth2" "oauth2_app_provider" {
  for_each = local.oauth2_apps

  name                  = format("Provider for %s", each.value.name)
  authorization_flow    = data.authentik_flow.implicit_consent.id
  invalidation_flow     = data.authentik_flow.default_invalidation_flow.id
  client_id             = each.value.client_id
  allowed_redirect_uris = [
    for uri in each.value.redirect_uris : {
      matching_mode = "strict"
      url           = uri
    }
  ]
  sub_mode              = "user_username"
  signing_key           = data.authentik_certificate_key_pair.self_signed.id
  access_token_validity = "minutes=5"
  property_mappings     = [
    data.authentik_property_mapping_provider_scope.oauth2_scope_openid.id,
    data.authentik_property_mapping_provider_scope.oauth2_scope_email.id,
    data.authentik_property_mapping_provider_scope.oauth2_scope_profile.id,
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

resource "grafana_sso_settings" "authentik_oauth2" {
  provider_name = "generic_oauth"
  oauth2_settings {
    name              = "Authentik"
    auth_url          = "https://auth.lab.omglolwtfbbq.com/application/o/authorize/"
    token_url         = "https://auth.lab.omglolwtfbbq.com/application/o/token/"
    api_url           = "https://auth.lab.omglolwtfbbq.com/application/o/userinfo/"
    client_id         = authentik_provider_oauth2.oauth2_app_provider["grafana"].client_id
    client_secret     = authentik_provider_oauth2.oauth2_app_provider["grafana"].client_secret
    allow_sign_up     = true
    auto_login        = false
    scopes            = "openid profile email"
    use_pkce          = true
    use_refresh_token = true

    # OIDC claims mapping
    login_attribute_path = "sub"
  }
}
