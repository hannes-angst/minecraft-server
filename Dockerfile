FROM alpine:3.10

MAINTAINER Hannes Angst <hannes@angst.email>

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
    apk add --no-cache curl jq bash openjdk11-jre-headless && \
    curl -sL "${MAJONG_MANIFEST}" -o manifest.json && \
    export MC_VERSION=`cat manifest.json | jq -r ".latest.release"` && \
    echo "*****************************" && \
    echo "Minecraft version: ${MC_VERSION}" && \
    echo "*****************************" && \
    export MC_ASSET=`cat manifest.json | jq -r '.versions[] | select(.id == "'${MC_VERSION}'" ) | .url '`   && \
    curl -sL "${MC_ASSET}" -o assets.json && \
    export MC_SERVER=`cat assets.json | jq -r ' .downloads.server.url '` && \
    curl -sL "${MC_SERVER}" -o /home/minecraft/server.jar && \
    rm assets.json manifest.json && \
    apk del curl jq bash  && \
    rm -rf /tmp/* /var/cache/apk/* && \
    chown -R minecraft:minecraft /home/minecraft

#
# It's always good to define this with java.
#
VOLUME /tmp
#
# Use the created space to work at
#
VOLUME /data

#
# Start folder
# minecraft writes to this folder.
#
WORKDIR /data

#
# Be the previously created user
#
USER minecraft


# Expose the container's network port: 25565 during runtime.
EXPOSE 25565

#Automatically accept Minecraft EULA, and start Minecraft server
CMD \
  echo eula=true >eula.txt && \
  java -server \
  -Xmx2048m -Xms2048m -Xmn1024m \
  -XX:+DisableExplicitGC \
  -XX:+UseAdaptiveGCBoundary \
  -XX:MaxGCPauseMillis=500 \
  -XX:-UseGCOverheadLimit \
  -XX:ParallelGCThreads=2 \
  -Djava.awt.headless=true \
  -Djava.security.egd=file:/dev/./urandom \
  -jar /home/minecraft/server.jar nogui
