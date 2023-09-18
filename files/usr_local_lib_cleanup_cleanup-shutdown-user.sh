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
   .local/state \
   .mozilla
find \( -name '.#*' -o -name '*~' -o -name '#*#' -o -name '*.swp' \) ! -type d -delete || :

test "$(id -u)" != 0 || exit 0

mkdir -p .config
: > .config/.setup-user

mkdir -p -m a=,u=rwx,g=rx .local/share/org.gnome.TextEditor
: > .local/share/org.gnome.TextEditor/session.gvariant

#WITH_VSCODIUM#
rm -fr .config/VSCodium

mkdir -p .config/VSCodium/User
cat > .config/VSCodium/User/settings.json <<\EOF
{
#WITH_RUST#
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.tabSize": 4
  },
  "[toml]": {
    "editor.defaultFormatter": "tamasfe.even-better-toml"
  },
#END_WITH_RUST#
  "editor.comments.ignoreEmptyLines": false,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.fontFamily": "JetBrains Mono Light",
  "editor.fontLigatures": true,
  "editor.fontSize": 14,
  "editor.formatOnPaste": true,
  "editor.formatOnSave": true,
  "editor.rulers": [100],
  "editor.suggest.showDeprecated": false,
  "editor.tabSize": 2,
  "editor.wordWrap": "on",
  "files.autoSave": "onFocusChange",
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.trimTrailingWhitespace": true,
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true
  },
  "html.format.extraLiners": "",
  "html.format.indentInnerHtml": true,
  "javascript.format.semicolons": "insert",
#WITH_RUST#
  "rust-analyzer.imports.granularity.enforce": true,
#END_WITH_RUST#
  "security.workspace.trust.enabled": false,
  "telemetry.telemetryLevel": "off",
  "terminal.integrated.allowChords": false,
  "terminal.integrated.detectLocale": "off",
  "terminal.integrated.fontFamily": "JetBrains Mono Light",
  "terminal.integrated.fontSize": 14,
  "terminal.integrated.shellIntegration.enabled": true,
  "terminal.integrated.smoothScrolling": true,
  "typescript.format.semicolons": "insert",
  "window.restoreFullscreen": true,
  "workbench.colorTheme": "Default Light Modern",
  "workbench.enableExperiments": false,
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "none"
}
EOF
#WITH_RUST#
cat > .config/VSCodium/User/keybindings.json <<\EOF
[
  {
    "command": "rust-analyzer.onEnter",
    "key": "Enter",
    "when": "editorTextFocus && !suggestWidgetVisible && editorLangId == rust"
  }
]
EOF
#END_WITH_RUST#

test -d .vscode-oss/extensions || {
    mkdir -p .vscode-oss/extensions
    cp --recursive /usr/local/lib/vscodium/extensions/* .vscode-oss/extensions
}

#END_WITH_VSCODIUM#
exit 0
