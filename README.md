# pi-cluster

Homelab services running on a Raspberry Pi.

## Setup

### Prerequisites
Clone the repository, including submodules:
```
$ git clone git@github.com:jeremyhayes/pi-docker-cluster.git --recurse-submodules
```

Copy and update any `env.template` files as needed.

### Install Docker and Compose
TODO

### Network

To allow all services to communicate, and to allow Traefik to monitor them, add all services to a single docker network created outside the scope of any group.

Create the network:
```
$ ./create-network.sh
```

### Services

Each service lives in a folder with a `docker-compose.yml` and any supporting configuration.

Start each service:
```
$ cd <service-dir>
$ sudo docker-compose up -d
```


## DNS

Create a wildcard A record DNS entry (e.g. `*.lab.example.com`). Services should be configured with Traefik labels to expose on a specific domain matching that wildcard (e.g. `foo.lab.example.com`).
