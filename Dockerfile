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
ENV DISTRO=etch
ENV CHROOT="/mnt/chroot"
RUN mkdir -p ${CHROOT}
RUN debootstrap --arch=amd64 --variant=minbase --no-check-gpg --exclude="     \
        bsdutils               \
        dselect                \
        e2fslibs               \
        e2fsprogs              \
        libblkid1              \
        libdevmapper1.02       \
        mount                  \
        hostname               \
        libcap1                \
        libdb4.3               \
        libpam0g               \
        libpam-modules         \
        libpam-runtime         \
        libuuid1               \
        login                  \
        passwd                 \
        procps                 \
        initscripts            \
        sysvinit               \
        sysvinit-utils         \
        libslang2              \
        util-linux             \
        libss2                 \
        lsb-base               \
        ncurses-base           \
        ncurses-bin            \
    " --include="dash" ${DISTRO} ${CHROOT} ${DEBIAN_ARCHIVE}

# Copy host timezone to target.
RUN ln -snf ${CHROOT}/usr/share/zoneinfo/$TZ ${CHROOT}/etc/localtime
RUN echo $TZ > ${CHROOT}/etc/timezone

# Copy host certificates to target.
RUN mkdir -p ${CHROOT}/etc/ssl/certs
RUN cd ${CHROOT}/etc/ssl && cp -rf /etc/ssl/certs/* certs/
RUN cd ${CHROOT}/etc/ssl && ln -s certs/certSIGN_ROOT_CA.pem cert.pem

# Add backports repository to target.
RUN chroot ${CHROOT} sh -c "                                                  \
    echo 'deb ${DEBIAN_ARCHIVE}-backports ${DISTRO}-backports main'           \
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
    echo 'Yes, do as I say!' | apt-get remove -y --force-yes bash             \
"

# Remove `debconf` after replacing `bash` with `dash`.
RUN chroot ${CHROOT} sh -c "                                                  \
    apt-get remove -y          \
        debconf                \
        debconf-i18n           \
        liblocale-gettext-perl \
        libtext-charwidth-perl \
        libtext-iconv-perl     \
        libtext-wrapi18n-perl  \
"

# Remove package leftovers.
RUN rm -rf ${CHROOT}/var/cache/debconf
RUN chroot ${CHROOT} sh -c "                                                  \
    dpkg --list | grep '^rc' | cut -d' ' -f3 | xargs dpkg --purge             \
"

# Remove bulky files in target unless mandatory.
RUN rm -rf ${CHROOT}/etc/cron.*
RUN rm -rf ${CHROOT}/etc/logrotate.d
RUN rm -rf ${CHROOT}/usr/games
RUN rm -rf ${CHROOT}/usr/local/games
RUN rm -rf ${CHROOT}/usr/share/emacs
RUN rm -rf ${CHROOT}/usr/share/vim
RUN rm -rf ${CHROOT}/var/cache/man
RUN find ${CHROOT}/usr/share/doc -mindepth 1 -type f                          \
    -not -name "copyright" -exec rm -rf {} \;
RUN find ${CHROOT}/usr/share/info -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
RUN find ${CHROOT}/usr/share/lintian/overrides -type f -exec rm {} \;
RUN find ${CHROOT}/usr/share/locale -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
RUN find ${CHROOT}/usr/share/man -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
RUN find ${CHROOT}/usr/share/zoneinfo -mindepth 1 -maxdepth 1 -not -regex     \
    ".*/\(GMT\|Greenwich|localtime|posix\|Universal|UTC|Zulu\).*\(\.tab\)?"   \
    -exec rm -rf {} \;
RUN find ${CHROOT}/var/cache/apt -type f -exec rm {} \;
RUN find ${CHROOT}/var/lib/apt/lists -type f -exec rm {} \;
RUN find ${CHROOT}/var/log -type f -exec rm {} \;
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
