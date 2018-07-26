# Cardanolite explorer =  - fork of cardano sl explorer node
FROM debian:jessie

LABEL name="Cardanolite explorer"
LABEL version="1.0.0"
LABEL description="Cardanolite explorer is a fork of Cardano SL explorer node"
LABEL maintainer="vacuumlabs, the creator of CardanoLite"

RUN apt-get update &&\
    apt-get install -y git curl bzip2 &&\
    useradd -ms /bin/bash cardano &&\
    mkdir -m 0755 /nix &&\
    chown cardano /nix &&\
    mkdir -p /etc/nix &&\
    echo binary-caches = https://cache.nixos.org https://hydra.iohk.io > /etc/nix/nix.conf &&\
    echo binary-cache-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= >> /etc/nix/nix.conf &&\
    su - cardano -c 'git clone https://github.com/vacuumlabs/cardanolite-sl.git /home/cardano/cardano-sl'


USER cardano
ENV USER cardano
RUN curl https://nixos.org/nix/install | sh

WORKDIR /home/cardano/cardano-sl
RUN git checkout cardanolite
RUN . /home/cardano/.nix-profile/etc/profile.d/nix.sh &&\
    nix-build release.nix -A connectScripts.mainnet.explorer -o connect-explorer-to-mainnet

EXPOSE 8100
CMD ./connect-explorer-to-mainnet
