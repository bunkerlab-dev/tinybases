ALL = $(shell echo "4 5 6")


build:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL); do                                               \
	        make build version="$$v" arch="$$arch";                       \
	    done                                                              \
	else                                                                  \
	    tag="tinybases/debian:$$version";                                 \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --platform=linux/amd64,linux/386                              \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)";                             \
	fi
