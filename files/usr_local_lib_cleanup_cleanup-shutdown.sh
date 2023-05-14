set -f

while IFS=: read -r username x uid rest; do
    if  test "$uid" -ge 1000 && test "$uid" -le 60000; then
        runuser -u "$username" -- \
                /bin/sh -e /usr/local/lib/cleanup/cleanup-shutdown-user.sh
    fi
done < /etc/passwd

/bin/sh -e /usr/local/lib/cleanup/cleanup-shutdown-user.sh

exec fstrim -v /
