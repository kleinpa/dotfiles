# If not running interactively, don't do anything
[ -z "$PS1" ] && return

if [ -d ~/.bashrc.d ]; then
    for file in $(/bin/ls ~/.bashrc.d/*); do
        . $file;
    done
fi
