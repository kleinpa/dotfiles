#!/usr/bin/env bash
choice=$(printf 'reload\nlock\nlogout\nsuspend\nreboot\nbios\nshutdown\nhelp' | fuzzel --dmenu --prompt='power: ' --lines=8)
case "$choice" in
    reload)  swaymsg reload ;;
    lock)    exec swaylock -f -F -e ;;
    logout)  swaymsg exit ;;
    suspend) systemctl suspend ;;
    reboot)  systemctl reboot ;;
    bios)    systemctl reboot --firmware-setup ;;
    shutdown) systemctl poweroff ;;
    help)    exec ~/.config/sway/scripts/keymap.sh ;;
esac
