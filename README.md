# tinybases

This `Dockerfile` generates light versions of the Debian images for use
in Docker containers. The cleanup process is done by removing unneeded
packages as well as other bulky files (e.g. documentation).

## Installation

1. Install [Docker].

2. Download the automated builds from the public [Docker Hub Registry]
   located at [tinybases].

## Usage

Given a Debian version `X`, you can run an interactive session as follows:
```sh
docker run --rm -it tinybases/debian:X
```

Given a Python version `X.Y`, you can run an interactive session as follows:
```sh
docker run --rm -it tinybases/python:X.Y-debian-5
```


[Docker]:
https://www.docker.com/
[Docker Hub Registry]:
https://hub.docker.com/
[tinybases]:
https://hub.docker.com/r/tinybases
