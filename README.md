# docker-debian-lean

This `Dockerfile` generates light versions of the Debian images for use
in Docker containers. The cleanup process is done by removing unneeded
packages as well as other bulky files (e.g. documentation).

## Installation

1. Install [Docker].

2. Download the automated build from the public [Docker Hub Registry]
   located at [tinybases/debian].

## Usage

Given a Debian version `X`, you can run an interactive session as follows:
```sh
docker run --rm -it tinybases/debian:X
```

[Docker]:
https://www.docker.com/
[Docker Hub Registry]:
https://hub.docker.com/
[tinybases/debian]:
https://hub.docker.com/r/tinybases/debian
