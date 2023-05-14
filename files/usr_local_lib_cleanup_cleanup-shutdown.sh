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

find /var/cache -mindepth 1 -delete
find /var/log -mindepth 1 -type f -name '*.[123456789]*' -delete
find /var/log -mindepth 1 -type f -exec truncate --size=0 '{}' +

exec fstrim -v /
