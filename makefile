ALL_DEBIAN_VERSIONS = $(shell echo "4 5 6")
ALL_PYTHON_VERSIONS = $(shell echo "2.6 2.7 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9")


build-debian:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL_DEBIAN_VERSIONS); do                               \
	        make build-debian version="$$v";                              \
	    done                                                              \
	else                                                                  \
	    tag="tinybases/debian:$$version";                                 \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --file Dockerfile.debian                                      \
	        --platform=linux/amd64,linux/386                              \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)";                             \
	fi


build-python:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL_PYTHON_VERSIONS); do                               \
	        make build-python version="$$v";                              \
	    done                                                              \
	else                                                                  \
	    tag="tinybases/python:$$version-debian-5";                        \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --file Dockerfile.python                                      \
	        --platform=linux/amd64,linux/386                              \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)";                             \
	fi
