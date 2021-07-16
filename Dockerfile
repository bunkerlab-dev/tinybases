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

# Set host timezone.
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
RUN echo ${TZ} > /etc/timezone

# Install host certificates.
RUN apt-get update && apt-get install -y ca-certificates && apt-get clean

# Install debootstrap.
RUN apt-get update && apt-get install -y debootstrap xz-utils && apt-get clean

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
                --exclude="${EXCLUDE}" --include="dash"                       \
                ${VERSION} ${CHROOT} ${DEBIAN_ARCHIVE}

# Copy host timezone to target.
RUN ln -snf ${CHROOT}/usr/share/zoneinfo/$TZ ${CHROOT}/etc/localtime
RUN echo $TZ > ${CHROOT}/etc/timezone

# Copy host certificates to target.
RUN mkdir -p ${CHROOT}/etc/ssl/certs
RUN cd ${CHROOT}/etc/ssl && cp -rf /etc/ssl/certs/* certs/
RUN cd ${CHROOT}/etc/ssl && ln -s certs/certSIGN_ROOT_CA.pem cert.pem

# Add backports repository to target.
RUN chroot ${CHROOT} sh -c "                                                  \
    distro_name=\$(cat /etc/apt/sources.list | head -n1 | cut -d' ' -f3);     \
    echo \"deb ${DEBIAN_ARCHIVE}-backports \${distro_name}-backports main\"   \
    >> /etc/apt/sources.list                                                  \
"
RUN chroot ${CHROOT} sh -c "                                                  \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EA8E8B2116BA136C \
"

# Delete root profiles in target.
RUN rm -f ${CHROOT}/root/.profile
RUN rm -f ${CHROOT}/root/.bashrc

# Update the dash prompt.
RUN sed -i "                                                                  \
        s|PS1='# '|PS1=\"[root@\$HOSTNAME \$PWD]# \"|;                        \
        s|PS1='\$ '|PS1=\"[\$USER@\$HOSTNAME \$PWD]\$ \"|;                    \
    " ${CHROOT}/etc/profile

# Fix `ldd` to be dash-compliant.
RUN sed -i 's|$"|"|; s|#! /bin/bash|#! /bin/sh|' ${CHROOT}/usr/bin/ldd
RUN sed -i 's|if \(set -o pipefail\) 2> /dev/null; then|if [ "${BASH_VERSION%%.*}" -ge 3 ]; then \1|' ${CHROOT}/usr/bin/ldd

# Remove bash-only `tzselect` until there is a valid fix.
RUN rm -f ${CHROOT}/usr/bin/tzselect

# Replace bash with dash.
RUN chroot ${CHROOT} sh -c "                                                  \
    echo 'dash dash/sh boolean true' | debconf-set-selections;                \
    dpkg-reconfigure dash;                                                    \
    echo 'Yes, do as I say!' | apt-get remove --purge -y --force-yes bash     \
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
        /usr/share/zoneinfo/*                                                 \
        /usr/share/vim                                                        \
        /var/cache/man                                                        \
    ; find                                                                    \
        /usr/share/lintian/overrides                                          \
        /var/cache/apt                                                        \
        /var/lib/apt/lists                                                    \
        /var/log                                                              \
        -type f | xargs rm -f                                                 \
    ; find                                                                    \
        /usr/share/info                                                       \
        /usr/share/locale                                                     \
        /usr/share/man                                                        \
        -mindepth 1 -maxdepth 1 | xargs rm -rf                                \
    ; find                                                                    \
        /usr/share/doc                                                        \
        -mindepth 1 -type f -not -name 'copyright' | xargs rm -rf             \
    ; find                                                                    \
        /usr/share/doc                                                        \
        -type d -name 'examples' | xargs rm -rf                               \
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
