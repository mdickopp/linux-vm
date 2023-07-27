while IFS=: read -r username x uid rest; do
    if  test "$uid" -ge 1000 && test "$uid" -le 60000; then
        runuser -l -s /bin/sh \
                -c 'exec /bin/sh -e /usr/local/lib/cleanup/cleanup-shutdown-user.sh' \
                -- "$username" < /dev/null
    fi
done < /etc/passwd

runuser -l -s /bin/sh \
        -c 'exec /bin/sh -e /usr/local/lib/cleanup/cleanup-shutdown-user.sh' \
        -- root < /dev/null

cat > /etc/default/keyboard <<\EOF
XKBMODEL="pc105"
XKBLAYOUT=""
XKBVARIANT=""
XKBOPTIONS="compose:rctrl"
BACKSPACE="guess"
EOF
: > /etc/.keyboard-configuration

find \
    /etc/NetworkManager/system-connections /var/lib/NetworkManager \
    /var/cache \
    -mindepth 1 -delete

rm -fr /var/log/apt
find /var/log -mindepth 1 -type f -name '*.[123456789]*' -delete
find /var/log -mindepth 1 -type f -exec truncate --size=0 '{}' +

exec fstrim -v /
