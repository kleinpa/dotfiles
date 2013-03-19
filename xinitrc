#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources


exec awesome
