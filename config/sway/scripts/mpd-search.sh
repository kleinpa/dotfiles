#!/usr/bin/env bash
track=$(mpc listall | fuzzel --dmenu --prompt='Music: ')
[ -n "$track" ] && mpc add "$track" && mpc play
