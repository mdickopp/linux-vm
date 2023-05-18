##############################################################################
# Set up environment
##############################################################################

exec < /dev/null

umask 022

unset LANG
unset LANGUAGE
unset LC_ADDRESS
unset LC_COLLATE
export LC_CTYPE=C.UTF-8
unset LC_IDENTIFICATION
unset LC_MEASUREMENT
unset LC_MESSAGES
unset LC_MONETARY
unset LC_NAME
unset LC_NUMERIC
unset LC_PAPER
unset LC_TELEPHONE
unset LC_TIME
unset LC_ALL

export DEBIAN_FRONTEND=noninteractive


##############################################################################
# Partition image file
##############################################################################

sfdisk "$image" <<\EOF
label: gpt
size=1M, type=21686148-6449-6E6F-744E-656564454649
type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF


##############################################################################
# Clean up temporary directory and loopback devices on exit
##############################################################################

tmpdir=
imgdev=
exit_action='
for sig in HUP INT PIPE TERM; do
    trap "" $sig
done
trap - EXIT
test -z "$imgdev" || losetup --detach "$imgdev"
test -z "$tmpdir" || rm -fr "$tmpdir"'

trap "$exit_action" EXIT
for sig in HUP INT PIPE TERM; do
    trap "{ $exit_action; } || :; trap - $sig; kill -$sig $$" $sig
done


##############################################################################
# Create temporary directory
##############################################################################

tmpdir=$(mktemp --directory --tmpdir linux-vm.XXXXXXXXXX)


##############################################################################
# Create loopback devices
##############################################################################

imgdev=$(losetup --partscan --show --find "$image")


##############################################################################
# Execute next stage in new mount namespace
##############################################################################

env \
    imgdev="$imgdev" \
    unshare -m -i -u -w "$tmpdir" /bin/sh -e "$srcdir/02-install.sh"

exit 0
