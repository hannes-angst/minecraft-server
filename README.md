# minecraft-server


Feature:
- Fetch latest minecraft server jar with curl and yq
- Based on alpine
- Uses none-root user
- Uses openJDK 1.8 headless (aka slim)


#Build

    $ docker build . --no-cache -t hangst/minecraft-server:<version>
    $ docker run -v $(pwd)/data:/data hangst/minecraft-server:<version>
    $ docker push hangst/minecraft-server:<version>
