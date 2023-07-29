# pi-cluster

Homelab services running on a Raspberry Pi.

## Prerequisites

0. Setup Raspberry Pi

    a. `raspi-config`
      - password
      - hostname
      - timezone
      - culture

    b. Static IP
      - `/etc/dhcpcd.conf`


1. Setup Docker

    a. Install Docker
      ```
      $ curl -fsSL https://get.docker.com -o get-docker.sh
      $ sudo sh ./get-docker.sh
      $ sudo usermod -aG docker pi
      ```

    b. Expose Docker daemon and metrics

      `/etc/docker/daemon.json`:
      ```
      {
        "hosts": [
          "tcp://0.0.0.0:2375",
          "unix:///var/run/docker.sock"
        ],
        "metrics-addr": "0.0.0.0:9323",
        "experimental": true
      }
      ```

      `/etc/systemd/system/docker.service.d/override.conf`:
      ```
      [Service]
      ExecStart=
      ExecStart=/usr/bin/dockerd
      ```

    c. Restart daemon service
      ```
      $ systemctl daemon-reload
      $ systemctl restart docker.service
      ```

2. Configure NFS share on primary/manager node

    a. Setup persistent mount for external hard drive
    > https://www.raspberrypi.org/documentation/configuration/external-storage.md

    b. Install NFS server
    ```
    $ apt install nfs-kernel-server
    ```

    c. Export NFS share directory via `/etc/exports`
    ```
    /mnt/hdd/share  192.168.42.0/24(rw,sync,no_subtree_check,no_root_squash)
    ```

3. Configure git client
```
$ apt install git
$ ssh-keygen -t ed25519 -C "your_email@example.com"
```
> NOTE: Copy generated public key to github config


## Docker Swarm

1. Initialize swarm from manager node
```
$ docker swarm init
```

2. Add each node to swarm

  a. If needed, get the join token from the manager node
  ```
  $ docker swarm join-token worker
  ```

  b. Join the worker node to the cluster
  ```
  $ docker swarm join --token <join-token> <manager-ip:port>
  ```


## Services

1. Clone the repository, including submodules:
```
$ git clone git@github.com:jeremyhayes/pi-cluster.git --recurse-submodules
```

2. Create any needed `.secret.xxx` files:
```sh
$ find ./docker-compose.yml | xargs grep "\.secret\."
# for each ...
nano .secret.xxx
```

2. Copy and update any `env.template` files as needed:
```
$ find . -name .env.template
# for each... 
$ cd <service-dir>
$ cp .env.template .env
$ nano .env
```

3. Deploy each service to a shared stack:
Each service lives in a folder with a `docker-compose.yml` and any supporting configuration.
```
$ ./deploy.sh <service-dir>
```
> NOTE: The first deploy will create an overlay network `<stack-name>_default`.

> IMPORTANT
> For services with externalized configuration (like credentials), `docker stack` does not resolve template placeholders from `.env` files. Instead, pipe the file through `docker-compose` as a preprocessor:
> ```
> docker stack deploy -c <(docker-compose config) stack-name-here
> ```


## DNS

Create a wildcard A record DNS entry (e.g. `*.lab.example.com`). Services should be configured with Traefik labels to expose on a specific domain matching that wildcard (e.g. `foo.lab.example.com`).
