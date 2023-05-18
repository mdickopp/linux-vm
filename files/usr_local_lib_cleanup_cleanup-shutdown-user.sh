rm -f \
   .*_history \
   .lesshst \
   .local/share/recently-used.xbel \
   .vboxclient-* \
   .viminfo
rm -fr \
   .cache \
   .config/dconf \
   .config/emacs/auto-save-list \
   .config/emacs/eln-cache \
   .config/pulse \
   .local/share/gvfs-metadata \
   .local/share/org.gnome.TextEditor \
   .local/share/xorg \
   .local/state
find \( -name '.#*' -o -name '*~' -o -name '#*#' -o -name '*.swp' \) ! -type d -delete || :

test "$(id -u)" != 0 || exit 0

mkdir -p .config
: > .config/.setup-user

mkdir -p -m a=,u=rwx,g=rx .local/share/org.gnome.TextEditor
: > .local/share/org.gnome.TextEditor/session.gvariant

exit 0
