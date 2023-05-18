rm -f .*_history .lesshst .vboxclient-* .viminfo
rm -fr \
   .cache \
   .config/dconf \
   .config/emacs/auto-save-list \
   .config/emacs/eln-cache \
   .config/pulse
find \( -name '.#*' -o -name '*~' -o -name '#*#' -o -name '*.swp' \) ! -type d -delete || :

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
