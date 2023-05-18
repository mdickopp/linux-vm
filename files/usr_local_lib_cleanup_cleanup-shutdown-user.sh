rm -f .*_history .lesshst .vboxclient-*
rm -fr .cache .config/dconf .config/pulse

test "$(id -u)" != 0 || exit 0

mkdir -p .config .local/share/applications/

: > .config/.setup-user

for i in emacs-mail emacs-term emacsclient emacsclient-mail; do
    cat > .local/share/applications/"$i.desktop" <<\EOF
[Desktop Entry]
Hidden=true
EOF
done

exit 0
