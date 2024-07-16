##############################################################################
# Feature-dependent variables
##############################################################################

extra_packages=
favorite_apps="'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox-esr.desktop'"


##############################################################################
# Install packages, remove unneeded packages
##############################################################################

case $features in
    */vscodium/*)
        mkdir -p /usr/local/share/keyrings
        cat "$srcdir/files/etc_apt_sources.list.d_vscodium.list" \
            > /etc/apt/sources.list.d/vscodium.list
        cat "$srcdir/files/usr_local_share_keyrings_vscodium.gpg" \
            > /usr/local/share/keyrings/vscodium.gpg
        extra_packages="$extra_packages codium fonts-jetbrains-mono"
        favorite_apps="$favorite_apps, 'codium.desktop'" ;;
esac

apt-get -y update
apt-get -y -o DPkg::Options::=--force-confold --purge dist-upgrade

aptitude -y markauto '~i(~slibs|~slocalization|~soldlibs|~sperl|~n-base\$|!~E)'

apt-get -y -o DPkg::Options::=--force-confold --purge install \
        linux-image-amd64

set -f
apt-get -y -o DPkg::Options::=--force-confold --purge --no-install-recommends install \
        bind9-host \
        build-essential \
        curl \
        dialog \
        emacs \
        fasttrack-archive-keyring \
        file \
        firefox-esr \
        fonts-liberation \
        fonts-noto \
        gedit \
        git \
        gnome-core \
        gnome-shell-extension-prefs \
        gnome-shell-extensions-extra \
        gnome-tweaks \
        grub-pc \
        iproute2 \
        iputils-ping \
        kbd \
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
        xauth \
        xserver-xorg \
        xserver-xorg-input-all \
        xserver-xorg-input-wacom \
        xz-utils \
        zip \
        $extra_packages
set +f

cat "$srcdir/files/etc_apt_sources.list+fasttrack" \
    >> /etc/apt/sources.list
apt-get -y update
apt-get -y -o DPkg::Options::=--force-confold --purge --no-install-recommends install \
        virtualbox-guest-utils \
        virtualbox-guest-x11

apt-get -y --purge purge \
        tasksel \
        whiptail

apt-get -y --purge autoremove
apt-get -y clean


##############################################################################
# Configure target system
##############################################################################

mkdir -p /etc/firefox-esr/policies
cat "$srcdir/files/etc_firefox-esr_firefox-esr.js" \
    >> /etc/firefox-esr/firefox-esr.js
cat "$srcdir/files/etc_firefox-esr_policies_policies.json" \
    > /etc/firefox-esr/policies/policies.json
cat "$srcdir/files/etc_gdm3_daemon.conf" \
    > /etc/gdm3/daemon.conf
cat "$srcdir/files/etc_gdm3_greeter.dconf-defaults" \
    > /etc/gdm3/greeter.dconf-defaults

rm -f /etc/skel/.face* /etc/skel/.bash_logout
patch --posix -f -d /etc/skel -F0 -N -p1 -u < "$srcdir/files/etc_skel_.bashrc.diff"
mkdir -p /etc/skel/.config/emacs
cat "$srcdir/files/etc_skel_.config_emacs_init.el" \
    > /etc/skel/.config/emacs/init.el
case $features in
    */rust/*)
        cat >> /etc/skel/.profile <<\EOF

PATH="$PATH:/opt/rust/toolchains/stable-x86_64-unknown-linux-gnu/bin"
MANPATH="$(manpath -q):/opt/rust/toolchains/stable-x86_64-unknown-linux-gnu/share/man"
export MANPATH
EOF
        printf 'RUSTUP_HOME=/opt/rust\n' >> /etc/environment ;;
esac

cat "$srcdir/files/etc_systemd_system_keyboard-configuration.service" \
    > /etc/systemd/system/keyboard-configuration.service
cat "$srcdir/files/etc_systemd_user_setup-user.service" \
    > /etc/systemd/user/setup-user.service

printf 'DefaultTimeoutStopSec=5s\n' >> /etc/systemd/system.conf

sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT[[:space:]=]/c\
GRUB_CMDLINE_LINUX_DEFAULT=""' /etc/default/grub

chmod -x /etc/X11/Xsession.d/98vboxadd-xclient
sed -i 's,^[[:space:]]*/usr/bin/VBoxClient[[:space:]]\+--\(draganddrop\|seamless\).*$,#&,' \
    /etc/X11/Xsession.d/98vboxadd-xclient

mkdir -p /usr/local/lib/cleanup /usr/local/share/applications
cat "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown.sh

sed_expr=
case $features in
    */rust/*) sed_expr="/^#\(END_\)\?WITH_RUST#/d;$sed_expr" ;;
    *) sed_expr="/^#WITH_RUST#/,/^#END_WITH_RUST#/d;$sed_expr" ;;
esac
case $features in
    */vscodium/*) sed_expr="/^#\(END_\)\?WITH_VSCODIUM#/d;$sed_expr" ;;
    *) sed_expr="/^#WITH_VSCODIUM#/,/^#END_WITH_VSCODIUM#/d;$sed_expr" ;;
esac
sed -e "$sed_expr" \
    "$srcdir/files/usr_local_lib_cleanup_cleanup-shutdown-user.sh" \
    > /usr/local/lib/cleanup/cleanup-shutdown-user.sh

sed "s/@FAVORITE_APPS@/$favorite_apps/" \
    "$srcdir/files/usr_local_lib_cleanup_setup-user.sh" \
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

systemctl --no-reload --force enable keyboard-configuration.service
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
# Install Rust (if requested)
##############################################################################

case $features in
    */rust/*)
        mkdir -p /opt/rust
        chown user:user /opt/rust
        runuser -l -s /bin/sh \
                -w http_proxy,https_proxy,no_proxy \
                -c 'curl --proto =https --tlsv1.2 -sSf -o rustup-init https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init && chmod +x rustup-init && RUSTUP_HOME=/opt/rust ./rustup-init -y --no-modify-path -c rust-src && rm -f rustup-init && rm -fr .cargo' \
                user
        chown -R root:root /opt/rust
        rm -fr /opt/rust/downloads /opt/rust/tmp
esac


##############################################################################
# Install VSCodium extensions (if VSCodium is installed)
##############################################################################

case $features in
    */vscodium/*)
        codium_install_extensions_cmd='codium --install-extension esbenp.prettier-vscode --install-extension PKief.material-icon-theme'
        case $features in
            */rust/*)
                codium_install_extensions_cmd="$codium_install_extensions_cmd --install-extension rust-lang.rust-analyzer --install-extension tamasfe.even-better-toml" ;;
        esac
        runuser -l -s /bin/sh \
                -w http_proxy,https_proxy,no_proxy \
                -c "$codium_install_extensions_cmd" \
                user
        mkdir -p  /usr/local/lib/vscodium/extensions
        cp --recursive /home/user/.vscode-oss/extensions/* \
           /usr/local/lib/vscodium/extensions
        rm -fr \
           /usr/local/lib/vscodium/extensions/extensions.json \
           /home/user/.vscode-oss ;;
esac


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
