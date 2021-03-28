# pi-cluster

Homelab services running on a Raspberry Pi.

## Network

Services are organized into individual subfolders/groups based on function, helping to reduce the size of each compose file. To allow all services to communicate, and to allow Traefik to monitor them, add all services to a single docker network created outside the scope of any group.

