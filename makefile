ALL = $(shell echo "4 5 6")


build:

	@if [ "$(version)" = "all" -o "$(version)" = "" ]; then               \
	    for v in $(ALL); do                                               \
	        make build version="$$v";                                     \
	    done                                                              \
	else                                                                  \
	    tag="debian-lean:$$version";                                      \
	    echo "Building $$tag...";                                         \
	    docker build --tag "$$tag" .                                      \
	        --build-arg VERSION="$(version)";                             \
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
