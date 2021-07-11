# pi-cluster

Homelab services running on a Raspberry Pi.

## Setup

### Prerequisites
0. Setup Pi
```
# change password
$ passwd

# set hostname
$ raspi-config

# set static ip
# nano /etc/dhcpcd.conf
```

1. Install Docker
```
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh ./get-docker.sh
$ sudo usermod -aG docker pi
```

2. Clone the repository, including submodules:
```
$ git clone git@github.com:jeremyhayes/pi-cluster.git --recurse-submodules
```

3. Copy and update any `env.template` files as needed.
```
$ find . -name .env.template
# for each... 
$ cd <service-dir>
$ cp .env.template .env
$ nano .env
```

4. Create shared network
To allow all services to communicate, and to allow Traefik to monitor them, add all services to a single docker network created outside the scope of any group.

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
