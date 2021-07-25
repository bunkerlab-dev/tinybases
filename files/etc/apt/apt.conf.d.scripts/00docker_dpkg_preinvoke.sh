#! /bin/sh


# Create some dummy locale folders.
for item in $(echo "af ar be bg bs ca cs cy da de dz el                \
                    en@boldquot en@quot en_GB eo es et eu              \
                    fi fr ga gl he hr hu id it ja km ko ku             \
                    ky lg lt mr ms nb ne nl nn no pa pl pt             \
                    pt_BR ro ru rw sk sl sr sv th tl tr uk             \
                    vi zh_CN zh_TW"); do
    mkdir -p /usr/share/locale/${item}/LC_MESSAGES
    mkdir -p /usr/share/locale/${item}/LC_TIME
done

# Create some dummy man folders.
for item in $(echo "de es fr hu ja man1 man3 man5 man7 man8            \
                    pl pt_BR ru sv"); do
    mkdir -p /usr/share/man/${item}
done
