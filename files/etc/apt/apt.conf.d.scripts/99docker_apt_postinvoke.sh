#! /bin/sh


# Remove apt cache.
find /var/cache/apt -type f -name "*.deb" | xargs rm -rf
find /var/cache/apt -type f -name "*.bin" | xargs rm -rf

# Remove backup files.
find /var -type f -name "*-old" | xargs rm -rf

# Remove apt logs.
find /var/log -type f | xargs rm -f

# Remove temporary files.
find                                                                          \
    /etc                                                                      \
    /var                                                                      \
    -regex ".*[~-]$" | xargs rm -rf
