#! /bin/sh


# Clean docs.
license_regex=".*/\(COPYING\|copyright\|LICEN[CS]E\|README\)*"
find                                                                          \
    /usr/share/doc                                                            \
    -mindepth 1 -type f                                                       \
    -not -regex "${license_regex}" | xargs rm -rf
# Remove doc folders and ended empty.
find                                                                          \
    /usr/share/doc                                                            \
    -type d -empty | xargs rm -rf
# Remove broken symlinks in docs.
find                                                                          \
    /usr/share/doc                                                            \
    -type l ! -exec test -e {} \; -print | xargs rm -rf
rm -rf /usr/share/groff/*
rm -rf /usr/share/info/*

# Remove lintian files.
rm -rf /usr/share/lintian/*
rm -rf /usr/share/linda/*

# Clean locales.
rm -rf /usr/share/locale/*

# Clean manpages.
rm -rf /usr/share/man/*
rm -rf /var/cache/man

# Undo dpkg cheat about `/bin/bash` if done during preinvoke script.
if [ -L /bin/bash ]; then
    rm -f /bin/bash
fi
