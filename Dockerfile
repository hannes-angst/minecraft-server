# Minecraft 1.x Dockerfile - Example with notes

# Use the offical Debian Docker image with a specified version tag, Stretch, so not all
# versions of Debian images are downloaded.
FROM alpine:3.9

MAINTAINER Hannes Angst <hannes@angst.email>

#
# It's always good to define this with java.
#
VOLUME /tmp

ENV MAJONG_MANIFEST https://launchermeta.mojang.com/mc/game/version_manifest.json


#
# Not sure about the IDs for group and user.
# However, we need be have an ID higher than 1024 (because of reasons)
#
ARG PGID=9002
ARG PUID=9002

RUN addgroup -g ${PGID} minecraft && \
    adduser -D -u ${PUID} -G minecraft minecraft && \
    mkdir -p /home/minecraft &&  \
    apk update  --no-cache &&  \
    apk upgrade --no-cache && \
    apk add --no-cache curl jq bash nss openjdk8-jre-base && \
    curl -sL "${MAJONG_MANIFEST}" -o manifest.json && \
    export MC_VERSION=`cat manifest.json | jq -r ".latest.release"` && \
    export MC_ASSET=`cat manifest.json | jq -r '.versions[] | select(.id == "'${MC_VERSION}'" ) | .url '`   && \
    curl -sL "${MC_ASSET}" -o assets.json && \
    export MC_SERVER=`cat assets.json | jq -r ' .downloads.server.url '` && \
    curl -sL "${MC_SERVER}" -o /home/minecraft/server.jar && \
    rm assets.json manifest.json && \
    apk del curl jq bash  && \
    rm -rf /tmp/* /var/cache/apk/* && \
    chown -R minecraft:minecraft /home/minecraft

# We do the above in a single line to reduce the number of layers in our container


# Sets working directory for the CMD instruction (also works for RUN, ENTRYPOINT commands)
# Create mount point, and mark it as holding externally mounted volume

#
# Use the created space to work at
#
WORKDIR /data
VOLUME /data

#
# Be the previously created user
#
USER minecraft


# Expose the container's network port: 25565 during runtime.
EXPOSE 25565

#Automatically accept Minecraft EULA, and start Minecraft server
CMD \
  echo eula=true > /data/eula.txt && \
  java -jar \
    \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+UseCGroupMemoryLimitForHeap \
    -XX:MaxRAMFraction=1 \
    -XX:+UseConcMarkSweepGC \
    \
    -Djava.awt.headless=true \
    -Djava.security.egd=file:/dev/./urandom \
    \
    /home/minecraft/server.jar
