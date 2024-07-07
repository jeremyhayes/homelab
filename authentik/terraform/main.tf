data "authentik_flow" "implicit_consent" {
  slug = "default-provider-authorization-implicit-consent"
}

# define forward auth proxy applications
locals {
  forward_auth_apps = tomap({
    whoami  = tomap({
      slug  = "whoami"
      name  = "WhoAmI"
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
}
