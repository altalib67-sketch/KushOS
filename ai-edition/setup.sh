#!/bin/sh
# KushOS AI Edition - setup on Alpine Linux (run as root).
# Installs the lightest serious stack: Ollama (on-demand),
# labwc + foot, NetSurf (+ Falkon on request), lite-xl + micro,
# and the RAM-saving tuning from AI_GOAL.md.
set -e

echo "== KushOS AI Edition setup (Alpine) =="

# --- packages ---
apk update
apk add labwc foot seatd xwayland \
        netsurf lite-xl micro \
        curl zram-init openrc

# --- full desktop stack (panel, launcher, notifications, OSD) ---
# These were missing from setup.sh before: without them `desktop`
# starts labwc but shows no panel, no launcher and no notifications.
apk add waybar fuzzel mako wob swaybg grim slurp brightnessctl \
        eudev dbus font-dejavu mesa-dri-gallium
# eudev (not mdev) must manage devices, or libinput finds no input
# devices and labwc refuses to start. seatd gives labwc the devices.
rc-update add udev sysinit || true
rc-update add udev-trigger sysinit || true
rc-update add udev-settle sysinit || true
rc-update add udev-postmount default || true
rc-update add seatd default || true
rc-update add dbus default || true

# --- Wi-Fi: supplicant + tools + firmware for common adapters ---
# linux-firmware-none satisfies the firmware-any dependency so the
# full ~800 MB firmware set is NOT pulled; we add the Wi-Fi vendors.
apk add wpa_supplicant iw linux-firmware-none \
        linux-firmware-brcm linux-firmware-cypress \
        linux-firmware-ath10k linux-firmware-ath11k \
        linux-firmware-rtlwifi linux-firmware-mediatek \
        linux-firmware-intel linux-firmware-qca \
        linux-firmware-ti-connectivity
mkdir -p /etc/wpa_supplicant
printf 'ctrl_interface=/var/run/wpa_supplicant\nupdate_config=1\n' \
    > /etc/wpa_supplicant/wpa_supplicant.conf
rc-update add wpa_supplicant default || true

# --- Sound, light media player, file manager, other disks ---
# ALSA only (no Pulse/PipeWire weight); mpv is the VLC-class player
# at a fraction of the size; pcmanfm manages files; ntfs-3g +
# exfatprogs make Windows disks fully readable/writable.
apk add alsa-utils mpv pcmanfm ntfs-3g exfatprogs util-linux \
        font-noto-arabic sakura
rc-update add alsa boot || true
# Arabic keyboard: labwc environment file sets
# XKB_DEFAULT_LAYOUT=us,ara + XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
# (Alt+Shift switches). mpv defaults live in ~/.config/mpv/mpv.conf
# (vo=wlshm so video works on any graphics). The `disks` helper in
# /usr/local/bin lists/mounts other disks under /media.

# Heavier modern-sites browser, only if you want it:
# apk add falkon

# --- Ollama: Alpine community package, else the official script ---
if ! apk add ollama 2>/dev/null; then
    echo "No Alpine ollama package - using the official installer"
    curl -fsSL https://ollama.com/install.sh | sh
fi

# --- Ollama tuning: one model, one request, unload after 2 min ---
mkdir -p /etc/profile.d
cat > /etc/profile.d/kushos-ai.sh <<'EOF'
export OLLAMA_KEEP_ALIVE=2m
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_FLASH_ATTENTION=1
EOF

# --- zram: compress half the RAM as swap (lz4) ---
cat > /etc/conf.d/zram-init <<'EOF'
load_on_start=yes
unload_on_stop=yes
num_devices=1
type0=swap
flag0="lz4"
size0=50%
EOF
rc-update add zram-init boot || true

# --- the `ai` command + model picker on PATH ---
install -m755 select-model.sh /usr/local/bin/select-model.sh
install -m755 ai /usr/local/bin/ai
install -m755 wifi /usr/local/bin/wifi
install -m755 disks /usr/local/bin/disks
install -m755 trash /usr/local/bin/trash
install -m755 vol /usr/local/bin/vol
install -m755 bright /usr/local/bin/bright
install -m755 shot /usr/local/bin/shot
install -m755 wallpaper /usr/local/bin/wallpaper
install -m755 setup /usr/local/bin/setup
mkdir -p /usr/share/kushos/icons /usr/share/pixmaps
cp desktop/icons/setup.svg /usr/share/kushos/icons/setup.svg
cp desktop/icons/setup.svg /usr/share/pixmaps/kushos-setup.svg
install -m755 desktop/desktop-launcher /usr/local/bin/desktop
install -m755 desktop/kushos-menu /usr/local/bin/kushos-menu

# --- desktop configs, welcome page, wallpapers ---
mkdir -p /usr/share/kushos/wallpapers /root/.config
cp -r desktop/labwc desktop/fuzzel desktop/mako desktop/wob \
      desktop/waybar desktop/foot desktop/mpv desktop/sakura \
      /root/.config/ 2>/dev/null || true
cp desktop/applications/*.desktop /usr/share/applications/ 2>/dev/null || true
cp desktop/welcome.html /usr/share/kushos/welcome.html
cp desktop/wallpapers/*.svg /usr/share/kushos/wallpapers/ 2>/dev/null || true
cp desktop/wallpapers/*.png /usr/share/kushos/wallpapers/ 2>/dev/null || true
cp desktop/wallpapers/*.jpg /usr/share/kushos/wallpapers/ 2>/dev/null || true
# Default wallpaper: meroe-pyramids if present, else the first one.
if [ -f /usr/share/kushos/wallpapers/meroe-pyramids.png ]; then
    ln -sf /usr/share/kushos/wallpapers/meroe-pyramids.png /usr/share/kushos/wallpaper.png
    echo meroe-pyramids > /usr/share/kushos/wallpaper-current
elif [ -n "$(ls /usr/share/kushos/wallpapers/*.png 2>/dev/null | head -1)" ]; then
    first=$(ls /usr/share/kushos/wallpapers/*.png | head -1)
    ln -sf "$first" /usr/share/kushos/wallpaper.png
    basename "$first" .png > /usr/share/kushos/wallpaper-current
fi
install -m644 kushos-locale.sh /etc/profile.d/kushos-locale.sh

echo "Done. Reboot, then: wifi (connect), ai (pick your model once)"
echo "Model for this machine: $(select-model.sh)"

# UTF-8 everywhere: /etc/profile.d/kushos-locale.sh exports
# LANG=C.UTF-8 + LC_ALL=C.UTF-8; the desktop launcher and the
# labwc environment file export the same for GUI apps. The default
# terminal is sakura (VTE) because it shapes Arabic text (HarfBuzz/
# FriBidi) - foot stays installed as a light backup terminal.
