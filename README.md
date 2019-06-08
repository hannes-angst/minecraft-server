# minecraft-server

## Feature

- Fetch latest minecraft server jar with curl and yq
- Based on alpine
- Uses none-root user
- Uses openJDK 1.8 headless (aka slim)


## Build

    $ docker build . --no-cache -t hangst/minecraft-server
    $ docker push hangst/minecraft-server

## Network
Keep in mind to map the exposed port to 25565 in order for clients to connect.


## Security
Keep in mind to allow rw access to the `data` volume. (GUID: 9002, PUID: 9002) 
