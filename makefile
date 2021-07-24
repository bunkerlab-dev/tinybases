ALL = $(shell echo "4 5 6")


build:

	@if [ "$(arch)" = "amd64" -o "$(arch)" = "" ]; then                   \
	    arch=amd64;                                                       \
	    platform=linux/amd64;                                             \
	elif [ "$(arch)" = "i386" ]; then                                     \
	    arch=i386;                                                        \
	    platform=linux/386;                                               \
	else                                                                  \
	    echo "E: invalid architecture: $(arch)";                          \
	    exit 1;                                                           \
	fi;                                                                   \
	if [ "$(version)" = "all" -o "$(version)" = "" ]; then                \
	    for v in $(ALL); do                                               \
	        make build version="$$v" arch="$$arch";                       \
	    done                                                              \
	else                                                                  \
	    tag="debian-lean:$$version-$$arch";                               \
	    echo "Building $$tag...";                                         \
	    docker build .                                                    \
	        --platform=$$platform                                         \
	        --tag "$$tag"                                                 \
	        --build-arg VERSION="$(version)"                              \
	        --build-arg ARCH="$$arch";                                    \
	fi


publish:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL); do                                               \
	        make publish version="$$v";                                   \
	    done;                                                             \
	else                                                                  \
	    user=tinybases;                                                   \
	    tag="debian-lean:$$version";                                      \
	    tagid=$$(docker images -q $$tag);                                 \
	    repotag=$$user/debian:$$version;                                  \
	    echo "Publishing $$repotag ($$tagid)...";                         \
	    docker tag "$$tagid" "$$repotag";                                 \
	    docker push "$$repotag";                                          \
	fi
