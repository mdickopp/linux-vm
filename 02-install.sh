##############################################################################
# Set hostname (within the separate UTS namespace)
##############################################################################

hostname "$(printf '%s' "$vm_hostname" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz)"


##############################################################################
# Create and mount target directory
##############################################################################

mke2fs -t ext4 -m 0 "${imgdev}p2"
mkdir target
mount "${imgdev}p2" target


##############################################################################
# Install Debian base system
##############################################################################

debootstrap \
    --arch=amd64 \
    --include=aptitude \
    bookworm target https://deb.debian.org/debian


#############################################################################
# Create essential configuration files
##############################################################################

mkdir -p \
      target/etc/apt \
      target/etc/default/grub.d \
      target/etc/dpkg/dpkg.cfg.d

cat > target/etc/fstab <<EOF
UUID=$(blkid -sUUID -ovalue "${imgdev}p2") /         ext4  errors=remount-ro                 0 1
tmpfs                                     /tmp      tmpfs nosuid,nodev,mode=1777,size=1024m 0 0
tmpfs                                     /var/tmp  tmpfs nosuid,nodev,mode=1777,size=512m  0 0
EOF

hostname > target/etc/hostname

# FIXME: Do not hard code timezone
ln -fs /usr/share/zoneinfo/Europe/Berlin target/etc/localtime

cat "$srcdir/files/etc_apt_sources.list" \
    > target/etc/apt/sources.list
cat "$srcdir/files/etc_default_grub.d_fast-boot.cfg" \
    > target/etc/default/grub.d/fast-boot.cfg
cat "$srcdir/files/etc_dpkg_dpkg.cfg.d_excludes" \
    > target/etc/dpkg/dpkg.cfg.d/excludes
cat "$srcdir/files/etc_kernel-img.conf" \
    > target/etc/kernel-img.conf


##############################################################################
# Set up chroot environment
##############################################################################

for dir in dev proc sys run tmp var/tmp; do
    rm -fr "target/$dir"
    mkdir -p "target/$dir"
done

mount --bind /dev     target/dev
mount --bind /dev/pts target/dev/pts
mount --bind /proc    target/proc
mount --bind /sys     target/sys

mount -t tmpfs -o nosuid,nodev,noexec,mode=775,size=512m   tmpfs target/run
mount -t tmpfs -o nosuid,nodev,noexec,mode=1777,size=1024m tmpfs target/tmp
mount -t tmpfs -o nosuid,nodev,noexec,mode=1777,size=512m  tmpfs target/var/tmp

mkdir target/run/.srcdir target/run/lock
mount --bind --read-only "$srcdir" target/run/.srcdir
chmod a=rwx,+t target/run/lock


##############################################################################
# Execute next stage in chroot environment
##############################################################################

exec env \
    srcdir=/run/.srcdir \
    chroot target /bin/sh -e /run/.srcdir/03-install-in-chroot.sh
