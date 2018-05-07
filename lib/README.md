# Cardanolite SL
A fork of [Cardano SL](https://github.com/input-output-hk/cardano-sl)

## Local installation

Based on [this guide](https://cardanodocs.com/for-contributors/building-from-source/)

get repo
```
git clone https://github.com/vacuumlabs/cardanolite-sl.git
cd ./cardanolite-sl
git checkout master
```

Install NixOs `curl https://nixos.org/nix/install | sh`

append line to your shell profile (~/.bashrc or ~/.zshrc) `/home/jamyUser/.nix-profile/etc/profile.d/nix.sh`

To employ the signed IOHK binary cache:
```
sudo mkdir -p /etc/nix
sudo vi /etc/nix/nix.conf
```

add these lines there
```
binary-caches            = https://cache.nixos.org https://hydra.iohk.io
binary-cache-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
```

### Build

from `cardanolite-sl/` wirh `source ~/.nix-profile/etc/profile.d/nix.sh` run
```
nix-build -A cardano-sl-explorer-static --cores 0 --max-jobs 2 --no-build-output --out-link master
nix-build -A connectScripts.mainnetExplorer -o connect-explorer-to-mainnet
```


## Run

from `cardanolite-sl/` wirh `source ~/.nix-profile/etc/profile.d/nix.sh` run  `./connect-explorer-to-mainnet`

## Dockerized installation

based on [this guide](https://github.com/EmurgoVN/cardano_docker)

assume You have installed docker

If you want to use DockerHub, you need an account and `docker login`. The [repository](https://hub.docker.com/r/janohreha/cardanolite-explorer/)  is private, so ask [CardanoLite team](mailto:cardanolite@vacuumlabs.com) for access.

### Get

##### A) Using DockerHub
You can pull image form rep (you have to be logged in `docker login`)
```
docker pull janohreha/cardanolite-explorer:1.0.0
```

or even just run `docker run` and it will look for image locally and if not succed then tires repository on DockerHub
```
docker run -d -v /data/cardano_docker_db:/home/cardano/cardano-sl/state-wallet-mainnet:Z -p 0.0.0.0:3000:8100 janohreha/cardanolite-explorer:1.0.0
```

##### B) Using image file

You need to load the file to Docker to recognize included image
```
docker load < filename
```


### Run

#### Prepare db volume
Before running Docker container hosting Cardano node it's important to define a volume on the host machine where to bind data : this means blockchain database and other data will be persisted on host environment and not inside the container itself. In case you need to stop/update or run again you container you won't loose you data. You need to create a folder somewhere on your environment and give access right to 'root' user.

```
sudo mkdir /data/cardano_docker_db
sudo chmod 777  /data/cardano_docker_db
```

#### Start

To start docker container and run CardanoLite explorer node run the following command. Successful run should return you the id of the container.
```
docker run -d --name=cardanolite-explorer -v /data/cardano_docker_db:/home/cardano/cardano-sl/state-wallet-mainnet:Z -p 0.0.0.0:3000:8100 janohreha/cardanolite-explorer:1.0.0
```

Command arguments :

- -d : run container in background
- -name : define the name of the Docker container
- -p : port binding, bind the 3000 of the host to the port 8100 inside the container. Port 8100 is the default port that CardanoLite explorer. Be careful that desired port are available on the host environment
- -v : bind volume, this option allows to bind volume/folder from inside the container to a volume on the host enivornment. This way you can keep all data (blockchain db) out of the container, you can delete and restart container without loosing your data.
- janohreha/cardanolite-explorer:1.0.0 : docker image id in this example, you can use image's hash

To list running containers run `docker ps -a`

to start(resume)/stop container run these commands
```
docker start cardanolite-explorer
```

```
docker stop cardanolite-explorer
```

to remove Docker image run  `docker rmi imageHash`

to remove Docker container run `docker rm containerId`

##### Verify node is running

Connect to API (if you run container with this port binded
```
curl -k http://localhost:3000/api/txs/last
```

To display container logs
```
docker logs -f cardano-explorer
```

### Build

in this repo
```
cd docker
```

you might want to set custom branch/tag/commit in line
```
RUN git checkout master
```
and custom build version
```
LABEL version="1.0.0"
```

run
```
docker build -t janohreha/cardanolite-explorer:1.0.0 .
```
with custom tag (`:1.0.0`)

### Publish
to list local Docker images run `docker images`

##### A) Using DockerHub

Push to the repository (you have to be logged in `docker login`)
```
docker push janohreha/cardanolite-explorer:1.0.0
```


##### B) Using image file

save image as a file
```
docker save -o ./filename ImageIdOrHash
```

copy do destination (e.g. aws)
```
scp ./filename  user@remote.host.com:/remote/path
```
