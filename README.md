# tinybases

This `Dockerfile` generates light versions of the Debian images for use
in Docker containers. The cleanup process is done by removing unneeded
packages as well as other bulky files (e.g. documentation).

## Installation

1. Install [Docker].

2. Download the automated builds from the public [Docker Hub Registry]
   located at [tinybases] and [pylegacy].

## Usage

Given a Debian version `X` (from 4 to 8), you can run an interactive
session as follows:
```sh
docker run --rm -it tinybases/debian:X
```

Given a Python version `X.Y` (from 2.6 to 3.9) and a Debian version `Z`
(from 4 to 8), you can run an interactive session as follows:
```sh
docker run --rm -it pylegacy/python:X.Y-debian-Z
```

Additionally, per-arch images are provided for x86 and x64 in the Docker
repositories `tinybases/x86-debian`, `tinybases/x64-debian`,
`pylegacy/x86-python` and `pylegacy/x64-python`.


[Docker]:
https://www.docker.com/
[Docker Hub Registry]:
https://hub.docker.com/
[tinybases]:
https://hub.docker.com/u/tinybases
[pylegacy]:
https://hub.docker.com/u/pylegacy
