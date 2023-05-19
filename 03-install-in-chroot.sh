##############################################################################
# Install required packages, remove unneeded packages
##############################################################################

apt-get -y update
apt-get -y -o DPkg::Options::=--force-confold --purge dist-upgrade

aptitude -y markauto '~i(~slibs|~slocalization|~soldlibs|~sperl|~n-base\$|!~E)'

apt-get -y -o DPkg::Options::=--force-confold --purge install \
        linux-image-amd64

apt-get -y -o DPkg::Options::=--force-confold --purge --no-install-recommends install \
        bind9-host \
        build-essential \
        emacs \
        file \
        firefox/sid libnss3/sid \
        fonts-liberation \
        fonts-liberation2 \
        fonts-noto \
        git \
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
        openssh-client \
        openssl \
        patch \
        strace \
        tcpdump \
        traceroute \
        unzip \
        vim-nox \
        virtualbox-guest-utils/sid virtualbox-guest-x11/sid \
        xauth \
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
# Configure target system
##############################################################################

mkdir -p /etc/firefox/policies
cat "$srcdir/files/etc_firefox_firefox.js" \
    >> /etc/firefox/firefox.js
cat "$srcdir/files/etc_firefox_policies_policies.json" \
    > /etc/firefox/policies/policies.json
cat "$srcdir/files/etc_gdm3_daemon.conf" \
    > /etc/gdm3/daemon.conf
cat "$srcdir/files/etc_gdm3_greeter.dconf-defaults" \
    > /etc/gdm3/greeter.dconf-defaults

rm -f /etc/skel/.face* /etc/skel/.bash_logout
patch --posix -f -d /etc/skel -F0 -N -p1 -u < "$srcdir/files/etc_skel_.bashrc.diff"
mkdir -p /etc/skel/.config/emacs
cat "$srcdir/files/etc_skel_.config_emacs_init.el" \
    > /etc/skel/.config/emacs/init.el

cat "$srcdir/files/etc_systemd_user_setup-user.service" \
    > /etc/systemd/user/setup-user.service

printf 'DefaultTimeoutStopSec=5s\n' >> /etc/systemd/system.conf

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT[[:space:]=]/c\
GRUB_CMDLINE_LINUX_DEFAULT=""' /etc/default/grub

chmod -x /etc/X11/Xsession.d/98vboxadd-xclient
sed -i 's,^[[:space:]]*/usr/bin/VBoxClient[[:space:]]\+--\(draganddrop\|seamless\).*$,#&,' \
    /etc/X11/Xsession.d/98vboxadd-xclient

mkdir -p /usr/local/lib/cleanup /usr/local/share/applications
cat "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown.sh
cat "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown-user.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown-user.sh
cat "$srcdir/files/usr_local_lib_cleanup_setup-user.sh" \
    > /usr/local/lib/cleanup/setup-user.sh
cat "$srcdir/files/usr_local_sbin_cleanup-shutdown" \
    > /usr/local/sbin/cleanup-shutdown
chmod +x /usr/local/sbin/cleanup-shutdown
for i in emacs-mail emacs-term emacsclient emacsclient-mail; do
    cat > "/usr/local/share/applications/$i.desktop" <<EOF
[Desktop Entry]
Name=$i
Type=Application
Hidden=true
EOF
done

systemctl --no-reload --force --global enable setup-user.service
systemctl mask \
          hibernate.target \
          hybrid-sleep.target \
          sleep.target \
          suspend-then-hibernate.target \
          suspend.target


##############################################################################
# Set up user accounts
##############################################################################

adduser --quiet --disabled-password --gecos User user
adduser user vboxsf
passwd -d root
passwd -d user

cp --recursive --preserve=mode /etc/skel/.[!.]* /root


##############################################################################
# Set up initramfs and grub
##############################################################################

update-initramfs -c -k all
update-grub
grub-install "$imgdev"


##############################################################################
# Perform cleanup
##############################################################################

rm -f \
   /var/log/alternatives.log \
   /var/log/dpkg.log \
   /var/log/fontconfig.log
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
