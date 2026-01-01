#!/command/with-contenv /usr/bin/bash

JSON=$(cat <<EOF
{
  "openid_connect": {
    "OAUTH_PKCE_ENABLED": true,
    "APPS": [
      {
        "provider_id": "authentik",
        "name": "Authentik",
        "client_id": "$(cat /run/secrets/authentik_paperless-client-id)",
        "secret": "$(cat /run/secrets/authentik_paperless-client-secret)",
        "settings": {
          "server_url": "https://auth.lab.omglolwtfbbq.com/application/o/paperless/.well-known/openid-configuration",
          "claims": {"username": "email"}
        }
      }
    ]
  }
}
EOF
)

echo "$JSON" > /run/s6/container_environment/PAPERLESS_SOCIALACCOUNT_PROVIDERS
