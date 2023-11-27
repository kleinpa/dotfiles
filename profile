[ -r ~/.profile.local ] && . ~/.profile.local

if [ -n $(command -v vim) ]; then
    export EDITOR=vim
elif [[ -n $(command -v nano) ]]; then
    export EDITOR=nano
fi