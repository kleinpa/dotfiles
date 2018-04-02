[ -r ~/.profile.local ] && . ~/.profile.local

if [ -n $(command -v emacs) ]; then
    export EDITOR=emacs
    export GIT_EDITOR="emacs -nw"
elif [[ -n $(command -v nano) ]]; then
    export EDITOR=nano
fi