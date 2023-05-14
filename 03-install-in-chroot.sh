##############################################################################
# Install required packages, remove unneeded packages
##############################################################################

apt-get -y update
apt-get -y -o DPkg::Options::=--force-confold --purge dist-upgrade

aptitude -y markauto '~i(~slibs|~slocalization|~soldlibs|~sperl|~n-base\$|!~E)'

apt-get -y -o DPkg::Options::=--force-confold --purge install \
        linux-image-amd64

apt-get -y -o DPkg::Options::=--force-confold --purge --no-install-recommends install \
        emacs \
        file \
        firefox/sid libnss3/sid \
        fonts-liberation \
        fonts-liberation2 \
        fonts-noto \
        gnome-core \
        gnome-shell-extension-prefs \
        gnome-shell-extensions-extra \
        gnome-tweaks \
        grub-pc \
        iproute2 \
        iputils-ping \
        libcap2-bin \
        locales \
        lsof \
        ltrace \
        manpages \
        netcat-openbsd \
        network-manager-gnome \
        nftables \
        openssl \
        strace \
        tcpdump \
        traceroute \
        unzip \
        vim-nox \
        virtualbox-guest-utils/sid virtualbox-guest-x11/sid \
        xserver-xorg \
        xserver-xorg-input-all \
        xserver-xorg-input-wacom \
        xz-utils \
        zip

apt-get -y --purge purge \
        tasksel

apt-get -y --purge autoremove
apt-get -y clean


##############################################################################
# Set up user accounts
##############################################################################

adduser --quiet --disabled-password --gecos User user
adduser user vboxsf
passwd -d root
passwd -d user


##############################################################################
# Configure target system
##############################################################################

cat "$srcdir/files/etc_gdm3_daemon.conf" \
    > /etc/gdm3/daemon.conf
cat "$srcdir/files/etc_gdm3_greeter.dconf-defaults" \
    > /etc/gdm3/greeter.dconf-defaults
cat "$srcdir/files/etc_systemd_user_setup-user.service" \
    > /etc/systemd/user/setup-user.service

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT[[:space:]=]/c\
GRUB_CMDLINE_LINUX_DEFAULT=""' /etc/default/grub

mkdir -p /usr/local/lib/cleanup
cat "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown.sh
cat "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown-user.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown-user.sh
cat "$srcdir/files/usr_local_lib_cleanup_setup-user.sh" \
    > /usr/local/lib/cleanup/setup-user.sh
cat "$srcdir/files/usr_local_sbin_cleanup-shutdown" \
    > /usr/local/sbin/cleanup-shutdown
chmod +x /usr/local/sbin/cleanup-shutdown

systemctl --no-reload --force --global enable setup-user.service


##############################################################################
# Set up initramfs and grub
##############################################################################

update-initramfs -c -k all
update-grub
grub-install "$imgdev"


##############################################################################
# Perform cleanup
##############################################################################

rm -fr \
   /etc/network \
   /var/log/bootstrap.log \
   /var/log/journal

find /usr/share/man \
     -mindepth 1 \
     ! -path '/usr/share/man/man*' \
     -delete
find /usr/share/locale \
     -mindepth 1 \
     ! -path /usr/share/locale/locale.alias \
     -delete

exec /bin/sh -e /usr/local/lib/cleanup/cleanup-shutdown.sh
