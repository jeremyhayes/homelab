# infinitude swarm service

## Prerequisites

1. Configure proxy in thermostat settings
  - Menu > Wireless > Advanced > Proxy
  - configure proxy IP address (not hostname)
  - configure proxy port

## Known Issues

- override entrypoint to invoke `c_rehash` before start
  - issue with ca_certificates package and/or libseccomp on host
  - https://github.com/nebulous/infinitude/issues/121

- not using traefik label-based configuration
  - Carrier Infinity thermostat would not make requests when proxy configured with hostname, but will with IPv4 address
  - use static route config instead

