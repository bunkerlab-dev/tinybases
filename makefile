ALL_DEBIAN_VERSIONS = $(shell echo "4 5 6")
ALL_PYTHON_VERSIONS = $(shell echo "2.6 2.6-ucs2 2.7 2.7-ucs2                 \
                                    3.1 3.1-ucs2 3.2 3.2-ucs2                 \
                                    3.3 3.4 3.5 3.6 3.7 3.8 3.9")


build-debian:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL_DEBIAN_VERSIONS); do                               \
	        make build-debian version="$$v" platform="$(platform)";       \
	    done                                                              \
	else                                                                  \
	    if [ "$(platform)" = "all" -o "$(platform)" = "" ]; then          \
	        plat="linux/amd64,linux/386";                                 \
	        tag="tinybases/debian:$$version";                             \
	    elif [ "$(platform)" = "amd64" ]; then                            \
	        plat="linux/amd64";                                           \
	        tag="tinybases/amd64-debian:$$version";                       \
	    elif [ "$(platform)" = "i386" ]; then                             \
	        plat="linux/386";                                             \
	        tag="tinybases/i386-debian:$$version";                        \
	    fi;                                                               \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --file Dockerfile.debian                                      \
	        --platform="$$plat"                                           \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)";                             \
	fi


build-python:

	@if [ "$(base)" = "all" -o "$(base)" = "" ]; then                     \
	    for v in $(ALL_DEBIAN_VERSIONS); do                               \
	        make build-python base="debian:$$v" version="$(version)"      \
	                          platform="$(platform)";                     \
	    done                                                              \
	elif [ "$(version)" = "all" -o "$(version)" = "" ]; then              \
	    for v in $(ALL_PYTHON_VERSIONS); do                               \
	        make build-python base="$(base)" version="$$v"                \
	                          platform="$(platform)";                     \
	    done                                                              \
	else                                                                  \
	    base_hyphenised="$(shell echo $(base) | tr ':' '-')";             \
	    if [ "$(platform)" = "all" -o "$(platform)" = "" ]; then          \
	        plat="linux/amd64,linux/386";                                 \
	        tag="tinybases/python:$$version-$$base_hyphenised";           \
	    elif [ "$(platform)" = "amd64" ]; then                            \
	        plat="linux/amd64";                                           \
	        tag="tinybases/amd64-python:$$version-$$base_hyphenised";     \
	    elif [ "$(platform)" = "i386" ]; then                             \
	        plat="linux/386";                                             \
	        tag="tinybases/i386-python:$$version-$$base_hyphenised";      \
	    fi;                                                               \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --file Dockerfile.python                                      \
	        --platform="$$plat"                                           \
	        --tag "$$tag"                                                 \
	        --build-arg BASE="$(base)"                                    \
	        --build-arg VERSION="$(version)";                             \
	fi
