# tinybases

This `Dockerfile` generates light versions of the Debian images for use
in Docker containers. The cleanup process is done by removing unneeded
packages as well as other bulky files (e.g. documentation).

## Installation

1. Install [Docker].

2. Download the automated builds from the public [Docker Hub Registry]
   located at [tinybases] and [pylegacy].

## Usage

Given a Debian version `X` (from 4 to 10), you can run an interactive
session as follows:
```sh
docker run --rm -it tinybases/debian:X
```

Given a Python version `X.Y` (from 2.6 to 3.12) and a Debian version `Z`
(from 4 to 10), you can run an interactive session as follows:
```sh
docker run --rm -it pylegacy/python:X.Y-debian-Z
```

Additionally, per-arch images are provided for x86 and x64 in the Docker
repositories [tinybases/x86-debian], [tinybases/x64-debian],
[pylegacy/x86-python] and [pylegacy/x64-python].

## Available symbols

Below you find the list of symbols available in the Debian-based Docker
images:

| &nbsp; &nbsp; &nbsp; Image &nbsp; &nbsp; &nbsp; | &nbsp; GLIBC &nbsp; | CXXABI   | GLIBCXX  | GCC   |
|-----------|---------|----------|----------|-------|
| Debian 4  | ≤ 2.3.4 | ≤ 1.3.1  | ≤ 3.4.8  | 4.1.2 |
| Debian 5  | ≤ 2.7   | ≤ 1.3.2  | ≤ 3.4.10 | 4.3.2 |
| Debian 6  | ≤ 2.11  | ≤ 1.3.3  | ≤ 3.4.13 | 4.4.5 |
| Debian 7  | ≤ 2.13  | ≤ 1.3.6  | ≤ 3.4.17 | 4.7.2 |
| Debian 8  | ≤ 2.18  | ≤ 1.3.8  | ≤ 3.4.20 | 4.9.2 |
| Debian 9  | ≤ 2.24  | ≤ 1.3.10 | ≤ 3.4.22 | 6.3.0 |
| Debian 10 | ≤ 2.28  | ≤ 1.3.11 | ≤ 3.4.25 | 8.3.0 |

The former list can be obtained by running the following code snippet
inside each Docker image:
```sh
apt-get update && apt-get install -y binutils gcc
find -L /lib* -name "libc.so.6" | xargs strings | grep "^GLIBC_"
find -L /usr/lib* -name "libstdc++.so.6" | xargs strings | grep "^CXXABI_"
find -L /usr/lib* -name "libstdc++.so.6" | xargs strings | grep "^GLIBCXX_"
/usr/bin/gcc --version
```

For comparison, the following table shows the list of symbols available
in CentOS and AlmaLinux:

| &nbsp; &nbsp; &nbsp; Image &nbsp; &nbsp; &nbsp; | &nbsp; GLIBC &nbsp; | CXXABI   | GLIBCXX  | GCC   |
|-------------|---------|----------|----------|--------|
| CentOS 5    | ≤ 2.5   | ≤ 1.3.1  | ≤ 3.4.8  |  4.1.2 |
| CentOS 6    | ≤ 2.12  | ≤ 1.3.3  | ≤ 3.4.13 |  4.4.7 |
| CentOS 7    | ≤ 2.17  | ≤ 1.3.7  | ≤ 3.4.19 |  4.8.5 |
| AlmaLinux 8 | ≤ 2.28  | ≤ 1.3.11 | ≤ 3.4.25 |  8.5.0 |
| AlmaLinux 9 | ≤ 2.34  | ≤ 1.3.13 | ≤ 3.4.29 | 11.3.1 |


[Docker]:
https://www.docker.com/
[Docker Hub Registry]:
https://hub.docker.com/
[tinybases]:
https://hub.docker.com/u/tinybases
[tinybases/x86-debian]:
https://hub.docker.com/r/tinybases/x86-debian
[tinybases/x64-debian]:
https://hub.docker.com/r/tinybases/x64-debian
[pylegacy]:
https://hub.docker.com/u/pylegacy
[pylegacy/x86-python]:
https://hub.docker.com/r/pylegacy/x86-python
[pylegacy/x64-python]:
https://hub.docker.com/r/pylegacy/x64-python
