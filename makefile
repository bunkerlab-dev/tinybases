ALL_DEBIAN_VERSIONS = $(shell echo "4 5 6 7 8 9")
ALL_PYTHON_VERSIONS = $(shell echo "2.6 2.6-ucs2 2.7 2.7-ucs2                 \
                                    3.1 3.1-ucs2 3.2 3.2-ucs2                 \
                                    3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10 3.11")


build-debian:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL_DEBIAN_VERSIONS); do                               \
	        make build-debian version="$$v" platform="$(platform)";       \
	    done                                                              \
	else                                                                  \
	    if [ "$(platform)" = "multiarch" -o "$(platform)" = "" ]; then    \
	        plat="linux/amd64,linux/386";                                 \
	        tag="tinybases/debian:$$version";                             \
	    elif [ "$(platform)" = "x64" ]; then                              \
	        plat="linux/amd64";                                           \
	        tag="tinybases/x64-debian:$$version";                         \
	    elif [ "$(platform)" = "x86" ]; then                              \
	        plat="linux/386";                                             \
	        tag="tinybases/x86-debian:$$version";                         \
	    fi;                                                               \
	    case "$(version)" in                                              \
	        4|etch)    SOURCE_DATE_EPOCH=1274486400 ;;                    \
	        5|lenny)   SOURCE_DATE_EPOCH=1331337600 ;;                    \
	        6|squeeze) SOURCE_DATE_EPOCH=1405728000 ;;                    \
	        7|wheezy)  SOURCE_DATE_EPOCH=1464998400 ;;                    \
	        8|jessie)  SOURCE_DATE_EPOCH=1529712000 ;;                    \
	        9|squeeze) SOURCE_DATE_EPOCH=1595030400 ;;                    \
	        10|buster) SOURCE_DATE_EPOCH=1656547200 ;;                    \
	        *)         SOURCE_DATE_EPOCH=0          ;;                    \
	    esac;                                                             \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --no-cache                                                    \
	        --provenance false                                            \
	        --file Dockerfile.debian                                      \
	        --platform "$$plat"                                           \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)"                              \
	        --build-arg SOURCE_DATE_EPOCH="$$SOURCE_DATE_EPOCH";          \
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
	    if [ "$(platform)" = "multiarch" -o "$(platform)" = "" ]; then    \
	        plat="linux/amd64,linux/386";                                 \
	        tag="pylegacy/python:$$version-$$base_hyphenised";            \
	    elif [ "$(platform)" = "x64" ]; then                              \
	        plat="linux/amd64";                                           \
	        tag="pylegacy/x64-python:$$version-$$base_hyphenised";        \
	    elif [ "$(platform)" = "x86" ]; then                              \
	        plat="linux/386";                                             \
	        tag="pylegacy/x86-python:$$version-$$base_hyphenised";        \
	    fi;                                                               \
	    echo "Building $$tag...";                                         \
	    docker buildx create --use;                                       \
	    docker buildx build .                                             \
	        --push                                                        \
	        --no-cache                                                    \
	        --provenance false                                            \
	        --file Dockerfile.python                                      \
	        --platform "$$plat"                                           \
	        --tag "$$tag"                                                 \
	        --build-arg BASE="$(base)"                                    \
	        --build-arg VERSION="$(version)";                             \
	fi
