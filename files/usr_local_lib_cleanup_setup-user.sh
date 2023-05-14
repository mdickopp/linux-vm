dconf load / <<\EOF
[desktop/ibus/panel]
show-icon-on-systray=false

[org/gnome/TextEditor]
custom-font='Liberation Mono 11'

[org/gnome/desktop/calendar]
show-weekdate=true

[org/gnome/desktop/input-sources]
sources=[('xkb', 'us'), ('xkb', 'de+nodeadkeys')]
xkb-options=['compose:rctrl']

[org/gnome/desktop/interface]
clock-show-seconds=true
clock-show-weekday=true
document-font-name='Cantarell 11'
font-antialiasing='rgba'
font-hinting='slight'
font-name='Cantarell 11'
monospace-font-name='Liberation Mono 11'
show-battery-percentage=true

[org/gnome/desktop/peripherals/touchpad]
tap-to-click=true

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/sound]
event-sounds=false

[org/gnome/desktop/wm/keybindings]
move-to-workspace-left=['<Control><Super>Left']
move-to-workspace-right=['<Control><Super>Right']

[org/gnome/desktop/wm/preferences]
action-middle-click-titlebar='lower'
button-layout='appmenu:minimize,maximize,close'
focus-mode='sloppy'
titlebar-font='Cantarell Bold 11'

[org/gnome/mutter]
edge-tiling=false

[org/gnome/nautilus/preferences]
default-folder-viewer='list-view'

[org/gnome/settings-daemon/plugins/media-keys]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']
volume-down=['AudioLowerVolume']
volume-mute=['AudioMute']
volume-up=['AudioRaiseVolume']

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Super>t'
command='x-terminal-emulator'
name='Launch Terminal'

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'

[org/gnome/shell]
disable-user-extensions=false
disabled-extensions=@as []
enabled-extensions=['workspace-indicator@gnome-shell-extensions.gcampax.github.com', 'no-overview@fthx']
favorite-apps=['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox.desktop']

[org/gnome/shell/app-switcher]
current-workspace-only=true

[org/gnome/software]
allow-updates=false
download-updates=false

[org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
cursor-blink-mode='off'
default-size-columns=80
default-size-rows=50
login-shell=true

[org/gtk/gtk4/settings/file-chooser]
show-hidden=true

[org/gtk/settings/file-chooser]
show-hidden=true

[system/proxy]
mode='auto'
EOF

exit 0
