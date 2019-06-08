# minecraft-server


Feature:
- Fetch latest minecraft server jar with curl and yq
- Based on alpine
- Uses none-root user
- Uses openJDK 1.8 headless (aka slim)


#Build

    $ docker build . --no-cache -t hangst/minecraft-server
    $ docker push hangst/minecraft-server
