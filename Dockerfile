# Host Docker image.
###############################################################################
FROM debian:buster-slim AS host

# Set environment variables.
ENV DEBIAN_ARCHIVE=http://archive.debian.org/debian
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC

# Install debootstrap.
RUN apt-get update && apt-get install -y debootstrap xz-utils && apt-get clean

# Install host certificates.
RUN apt-get update && apt-get install -y wget ca-certificates && apt-get clean

# Retrieve a static `wget`.
RUN wget https://raw.githubusercontent.com/minos-org/minos-static/master/static-get \
    && chmod +x static-get                                                    \
    && mkdir -p /opt/wget                                                     \
    && ./static-get wget                                                      \
    && tar -xf wget.tar.xz --directory /opt/wget                              \
    && rm -rf /opt/wget/etc /opt/wget/man                                     \
    && rm -rf /opt/wget/doc/wget/AUTHORS                                      \
    && rm -rf /opt/wget/doc/wget/NEWS                                         \
    && rm wget.tar.xz                                                         \
    && rm static-get

# Prepare target.
ENV CHROOT="/mnt/chroot"
RUN mkdir -p ${CHROOT}

# Apply debootstrap.
ARG VERSION
RUN case "${VERSION}" in                                                      \
        4|etch)                                                               \
            VERSION=etch                                                      \
            EXCLUDE=$(echo "                                                  \
                bsdutils                                                      \
                dselect                                                       \
                e2fslibs                                                      \
                e2fsprogs                                                     \
                libblkid1                                                     \
                libdevmapper1.02                                              \
                mount                                                         \
                hostname                                                      \
                libcap1                                                       \
                libdb4.3                                                      \
                libpam0g                                                      \
                libpam-modules                                                \
                libpam-runtime                                                \
                libuuid1                                                      \
                login                                                         \
                passwd                                                        \
                procps                                                        \
                initscripts                                                   \
                sysvinit                                                      \
                libslang2                                                     \
                util-linux                                                    \
                libss2                                                        \
                lsb-base                                                      \
                ncurses-base                                                  \
                ncurses-bin                                                   \
            " | xargs)                                                        \
        ;;                                                                    \
        5|lenny)                                                              \
            VERSION=lenny                                                     \
            EXCLUDE=$(echo "                                                  \
                bsdutils                                                      \
                dselect                                                       \
                e2fslibs                                                      \
                e2fsprogs                                                     \
                libblkid1                                                     \
                libdevmapper1.02.1                                            \
                hostname                                                      \
                libcap1                                                       \
                libdb4.3                                                      \
                libpam0g                                                      \
                libpam-modules                                                \
                libpam-runtime                                                \
                libuuid1                                                      \
                login                                                         \
                passwd                                                        \
                procps                                                        \
                initscripts                                                   \
                sysvinit                                                      \
                mount                                                         \
                libslang2                                                     \
                util-linux                                                    \
                libss2                                                        \
                lsb-base                                                      \
                ncurses-base                                                  \
                ncurses-bin                                                   \
                gcc-4.2-base                                                  \
            " | xargs)                                                        \
        ;;                                                                    \
        6|squeeze)                                                            \
            VERSION=squeeze                                                   \
            EXCLUDE=$(echo "                                                  \
                bsdutils                                                      \
                dselect                                                       \
                e2fslibs                                                      \
                e2fsprogs                                                     \
                libblkid1                                                     \
                hostname                                                      \
                libpam0g                                                      \
                libpam-modules                                                \
                libpam-runtime                                                \
                libuuid1                                                      \
                login                                                         \
                passwd                                                        \
                procps                                                        \
                initscripts                                                   \
                sysvinit                                                      \
                mount                                                         \
                tzdata                                                        \
                util-linux                                                    \
                libss2                                                        \
                lsb-base                                                      \
                ncurses-base                                                  \
                ncurses-bin                                                   \
            " | xargs)                                                        \
        ;;                                                                    \
    esac;                                                                     \
    debootstrap --arch=amd64 --variant=minbase --no-check-gpg                 \
                --exclude="${EXCLUDE}" --include="dash patch"                 \
                ${VERSION} ${CHROOT} ${DEBIAN_ARCHIVE}

# Copy `/etc/profile` from outside and delete root profiles in target.
COPY files/etc/profile ${CHROOT}/etc/profile
RUN rm -f ${CHROOT}/root/.profile
RUN rm -f ${CHROOT}/root/.bashrc

# Copy host timezone to target.
RUN echo ${TZ} > ${CHROOT}/etc/timezone

# Add backports repository to target.
RUN chroot ${CHROOT} sh -c "                                                  \
    distro_name=\$(cat /etc/apt/sources.list | head -n1 | cut -d' ' -f3);     \
    echo \"deb ${DEBIAN_ARCHIVE}-backports \${distro_name}-backports main\"   \
    >> /etc/apt/sources.list                                                  \
"
RUN chroot ${CHROOT} sh -c "                                                  \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EA8E8B2116BA136C \
"

# Fix `ldd` to be dash-compliant.
RUN sed -i 's|$"|"|; s|#! /bin/bash|#! /bin/sh|' ${CHROOT}/usr/bin/ldd
RUN sed -i 's|if \(set -o pipefail\) 2> /dev/null; then|if [ "${BASH_VERSION%%.*}" -ge 3 ]; then \1|' ${CHROOT}/usr/bin/ldd

# Replace bash with dash (cheat the system with a symlink if needed).
RUN chroot ${CHROOT} sh -c "                                                  \
    echo 'dash dash/sh boolean true' | debconf-set-selections;                \
    dpkg-reconfigure dash;                                                    \
"

# Inject host certificates into target.
RUN mkdir -p ${CHROOT}/etc/ssl/certs
RUN cp /etc/ssl/certs/ca-certificates.crt ${CHROOT}/etc/ssl/cert.pem

# Inject the static `wget` in the host and configure the CA certificates.
RUN cp -R /opt/wget ${CHROOT}/opt/wget                                      &&\
    chroot ${CHROOT} sh -c "                                                  \
        ln -s /opt/wget/bin/wget /usr/bin/wget;                               \
        echo 'ca_certificate=/etc/ssl/cert.pem' > /etc/wgetrc;                \
    "

# Tell dpkg not to install unnecessary stuff.
RUN chroot ${CHROOT} sh -c "                                                  \
    mkdir -p /etc/dpkg/dpkg.cfg.d;                                            \
    {                                                                         \
    echo '# Remove all docs but the copyright files';                         \
    echo 'path-exclude /usr/share/doc/*';                                     \
    echo 'path-include /usr/share/doc/*/copyright';                           \
    echo 'path-exclude /usr/share/man/*';                                     \
    echo 'path-exclude /usr/share/groff/*';                                   \
    echo 'path-exclude /usr/share/info/*';                                    \
    echo '# Remove lintian files';                                            \
    echo 'path-exclude /usr/share/lintian/*';                                 \
    echo 'path-exclude /usr/share/linda/*';                                   \
    } > /etc/dpkg/dpkg.cfg.d/01_nodoc;                                        \
"

# Specific removal for Debian Lenny.
RUN rm -f ${CHROOT}/usr/bin/oldfind

# Remove bulky files in target unless mandatory.
RUN chroot ${CHROOT} sh -c "                                                  \
      rm -rf                                                                  \
        /etc/cron.*                                                           \
        /etc/logrotate.d                                                      \
        /usr/games                                                            \
        /usr/local/games                                                      \
        /usr/share/emacs                                                      \
        /usr/share/info/*                                                     \
        /usr/share/groff/*                                                    \
        /usr/share/linda/*                                                    \
        /usr/share/lintian/*                                                  \
        /usr/share/locale/*                                                   \
        /usr/share/man/*                                                      \
        /usr/share/vim                                                        \
        /usr/share/zoneinfo/*                                                 \
        /var/cache/man                                                        \
    ; find                                                                    \
        /var/cache/apt                                                        \
        /var/lib/apt/lists                                                    \
        /var/log                                                              \
        -type f | xargs rm -f                                                 \
    ; find                                                                    \
        /usr/share/doc                                                        \
        -mindepth 1 -type f -not -name 'copyright' | xargs rm -rf             \
    ; find                                                                    \
        /usr/share/doc                                                        \
        -empty | xargs rm -rf                                                 \
"
###############################################################################


# Target Docker image.
###############################################################################
FROM scratch AS debian-lean

# Set environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=POSIX
ENV LANGUAGE=POSIX
ENV LC_ALL=POSIX
ENV TZ=UTC

# Copy rootfs from host.
ENV ENV="/etc/profile"
ENV CHROOT="/mnt/chroot"
COPY --from=host ${CHROOT} /

# Launch shell.
CMD ["sh"]
###############################################################################
