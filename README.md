# KushOS — AI Edition

نظام تشغيل خفيف جدًا مبني على Alpine Linux — يشتغل بالذكاء الاصطناعي
على أي جهاز، وبيستهلك جزء بسيط من رام ويندوز.

A featherweight operating system built on Alpine Linux. It runs AI
models locally on almost any machine, in a fraction of Windows' RAM.

**Measured (QEMU, 1 GB guest): 83 MB idle · 131 MB full desktop.**
Windows 11 idles at 4–6 GB. KushOS is roughly 2–3% of that.

## Download | التنزيل

Ready-to-boot ISO image (~881 MB):
https://drive.google.com/file/d/1630H27Eg-fYPR6gu1oyLUsR7xcTUoD8J/view?usp=drivesdk

Write it to a USB stick (8 GB+) with Rufus in **ISO mode** (or
`dd`/`balenaEtcher`), then boot from it. It boots on both **UEFI**
(GPT target in Rufus, Secure Boot disabled) and **Legacy BIOS**
(CSM). It also runs in any VM (QEMU/VirtualBox) — just attach the
ISO as a hard disk or CD.

Log in as `root` (password `kushos`), then type `desktop` for the
graphical desktop, or `ai` to start the AI right away.

## What works | ما يعمل

- **Local AI (Ollama)** — type `ai`: a menu of models with sizes
  (0.5B → 8B); the best fit for your RAM is marked. Pick once, it
  downloads once. One model loaded at a time, auto-unloads after
  2 minutes idle, zram swap. No account, no cloud, no tracking.
- **Browser** — NetSurf (very light) for the web + a local Arabic
  start page; Falkon can be added for heavy sites.
- **Code editor** — lite-xl, opens instantly.
- **Desktop (labwc / Wayland)** — glass theme, bottom panel with
  live volume / battery / network pills, a native C launcher
  (fuzzel) with search and icons, notifications (mako),
  on-screen volume/brightness bar, Print-key screenshots.
- **Arabic everywhere** — full UTF-8 system, Alt+Shift keyboard
  switching (US ⇄ Arabic), a terminal (sakura/VTE) that shapes
  Arabic correctly, Arabic file names.
- **Wi-Fi** — `wifi` command (scan → pick → password); firmware for
  Intel / Broadcom / Qualcomm / Realtek / MediaTek adapters.
- **Files & disks** — PCManFM file manager; `disks` mounts other
  drives (NTFS / FAT / exFAT, read **and write**) under /media.
  The system disk is a normal writable install — your files,
  models and settings persist across reboots from USB.
- **Trash can** — real freedesktop trash: PCManFM's Trash Can plus
  a terminal command: `trash file`, `trash list`,
  `trash restore name`, `trash empty`.
- **Wallpapers** — four Kush-inspired desktops (Meroe pyramids,
  the Nile at sunset, a Nubian village, a Kushite temple):
  `wallpaper list`, `wallpaper meroe-pyramids`, `wallpaper next`.
  SVG sources live in `ai-edition/desktop/wallpapers/`.
- **Media** — mpv player + ALSA sound out of the box.

## Useful commands | أوامر مفيدة

```
ai              AI chat (first run: pick a model for your RAM)
wifi            connect to Wi-Fi   (wifi scan|status|off)
disks           list disks         (disks mount sdb1)
trash           trash can          (trash list|restore|empty)
vol up|down     volume             (also the Fn keys)
shot            screenshot to ~/Pictures (also the Print key)
desktop         start the graphical desktop from tty1
wallpaper list  change the desktop wallpaper (wallpaper next)
```

## Repository layout | ملفات المشروع

```
ai-edition/
  AI_GOAL.md          design notes, memory rules, model-by-RAM table
  setup.sh            installs the whole system onto Alpine Linux
  ai                  the `ai` launcher script
  select-model.sh     RAM -> recommended model
  wifi  disks  trash  vol  bright  shot  wallpaper  system commands
  kushos-locale.sh   UTF-8 locale profile
  desktop/            every desktop config, mirrored 1:1 into
                      ~/.config of the image:
                      labwc (compositor, keybinds, menus),
                      waybar (panel), fuzzel (launcher),
                      mako (notifications), wob (OSD),
                      sakura (terminal), mpv, applications/,
                      wallpapers/ (Kush-inspired wallpapers, SVG sources)
```

## Develop | للتطوير

The image is assembled from a plain Alpine 3.24 rootfs; every
customisation lives in this repo as a text file:

1. Install Alpine, run `ai-edition/setup.sh` — or unpack any
   Alpine minirootfs and copy the scripts/configs in.
2. Scripts go to `/usr/local/bin`, desktop configs to
   `/root/.config` (see `ai-edition/desktop/`).
3. Boot it in QEMU and measure: `free -m` is the project's
   scoreboard. The rule for every change: **prettier is welcome,
   slower is not** — the full desktop budget is ~130 MB.

Pull requests welcome. Ideas on the roadmap: full GPU support
(Mesa/Vulkan + AMD firmware), Bluetooth, a first-run wizard, and
suspend-on-lid-close.

## History note

KushOS began as a from-scratch BIOS kernel with a glass GUI
(v1.2, booted in 4 MB RAM). That code was removed from this repo
on 2026-11-16 so the project presents one clear product — the AI
Edition. The kernel sources remain in the project's local
archive; the v1.2 notes live in the release package.
