# If not running interactively, don't do anything
[ -z "$PS1" ] && return

if [ -d "$HOME/.bashrc.d" ]; then
    for file in "$HOME/.bashrc.d/"*; do
        [ -f "$file" ] || continue
        . "$file"
    done
fi
