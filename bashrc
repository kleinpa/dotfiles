# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
    source /usr/lib/git-core/git-sh-prompt
    PS1_GIT="\$(__git_ps1)"
fi

if [[ -e ~/.bashrc.local ]]; then
   source ~/.bashrc.local
fi


hue_to_ansi256() {
    # map hue (from 0-1536) to saturated ansi256 color
    h=$1
    n=$(( ((h)/256)%6 ))

    x=$((h%256))
    y=$((256-x))

    r=$(( (n==0? 255 :(n==1? y   :(n==2? 0   :(n==3? 100 :(n==4? x   :(n==5? 255 :0)))))) ))
    g=$(( (n==0? x   :(n==1? 255 :(n==2? 255 :(n==3? y   :(n==4? 100 :(n==5? 0   :0)))))) ))
    b=$(( (n==0? 0   :(n==1? 0   :(n==2? x   :(n==3? 255 :(n==4? 255 :(n==5? y   :0)))))) ))
    printf "%03d" $(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))
}

hue_to_ansi8() {
    # map hue (from 0-1536) to saturated ansi256 color
    h=$1
    n=$(( ((h+128)/256)%6 ))
    case $n in
        0) echo 1 ;;
        1) echo 3 ;;
        2) echo 2 ;;
        3) echo 6 ;;
        4) echo 4 ;;
        5) echo 5 ;;
    esac
}

hex_to_ansi256() {
    # http://unix.stackexchange.com/a/269085/67282
    r=$(printf '0x%0.2s' "$1")
    g=$(printf '0x%0.2s' ${1#??})
    b=$(printf '0x%0.2s' ${1#????})
    printf "%03d" $(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))
}

set_fg() {
    case $1 in
        reset) echo "\e[0m" ;;
        bold) echo "\e[1;3${2}m" ;;
        hash256) echo "\e[38;5;$(hue_to_ansi256 $(( $(cksum <<< ${2} | cut -f 1 -d ' ') % 1280 + 128)))m" ;;
        hash8) echo "\e[1;3$(hue_to_ansi8 $(( $(cksum <<< ${2} | cut -f 1 -d ' ') % 1280 + 128)))m" ;;
        hex) echo "\e[38;5;$(hex_to_ansi256 $2)m" ;;
        *) echo "\e[38;5;$(hex_to_ansi256 $1)m" ;;
    esac
}

case $([ "$TERM" != cygwin ] && [ -x '/usr/bin/tput' ] && tput colors) in
    256)
        [ $(id -u) = 0 ] && prompt_color=ff0000
        C1=$(set_fg ${prompt_color:-hash256 $(hostname)}) # Color for name, system, directory
        C0=$(set_fg ${prompt_color_brackets:-reset})          # White for @ : () %
        C2=$(set_fg ${prompt_color_git:-bold 7})              # Color for GIT info
        alias emacs='TERM=xterm-256color emacs'
        ;;
    8)
        [ $(id -u) = 0 ] && prompt_color="bold 1"
        C1=$(set_fg ${prompt_color:-hash8 $(hostname)}) # Color for name, system, directory
        C0=$(set_fg ${prompt_color_brackets:-reset})          # White for @ : () %
        C2=$(set_fg ${prompt_color_git:-bold 7})              # Color for GIT info
        ;;
    *)
        C0=""
        C1=""
        C2=""
        ;;
esac

fi

PS1="\[${C1}\]\u\[${C0}\]@\[${C1}\]\h\[${C0}\]:\[${C1}\]\W\[${C2}\]${PS1_GIT}\[\033[0m\]\$ "

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export EDITOR='emacs'

alias e='$EDITOR'

hash -d p=~/projects/
