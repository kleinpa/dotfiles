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

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

if [ "$EMACS" = t ]; then
    color_prompt=yes
fi

if [ "$color_prompt" = yes ]; then
    C0="\[\033[0;37m\]"     # White for @ : () %
    C1="\[\033[1;35m\]"     # Color for name, system, directory
    C2="\[\033[1;34m\]"     # Color for GIT info
    PS1="${C1}\u${C0}@${C1}\h${C0}:${C1}\W${C2}${PS1_GIT}\[\033[0m\]\$ "
else
    PS1='\u@\h:\w\$ '
fi

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
