#!/command/with-contenv /usr/bin/bash

json=$(cat <<EOF
{
    "openid_connect": {
        "OAUTH_PKCE_ENABLED": True,
        "APPS": [{
            "provider_id": "authentik",
            "name": "Authentik",
            "client_id": "$(cat /run/secrets/authentik_paperless-client-id)",
            "secret": "$(cat /run/secrets/authentik_paperless-client-secret)",
            "settings": {
                "server_url": "http://auth.lab.omglolwtfbbq.local",
                "claims": {"username": "email"}
            },
        }],
    }
}
EOF
)

cat "${json}" > "${PAPERLESS_SOCIALACCOUNT_PROVIDERS}"
