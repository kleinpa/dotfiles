# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export PATH=$HOME/bin:$HOME/.bin:$PATH

hash -d p=~/projects/

alias cp='cp -i'
alias e='$EDITOR'
alias ev='$VISUAL'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='less'
alias less='less -I'
alias ll='ls -ahl'
alias ls="ls --color=auto --file-type"
alias ls='ls --color=auto'
alias mv='mv -i'

# Windows Subsystem for Linux
if grep -q Microsoft /proc/version; then
    alias emacs='emacsclientw.exe -na runemacs'
    alias open='cmd.exe /c START'
fi

#alias emacs='emacsclient -c -nw --alternate-editor="emacs"'
export EDITOR="emacsclient --tty --alternate-editor \"\""
export VISUAL="emacsclient --create-frame --no-wait --alternate-editor \"\""

shopt -s checkwinsize
shopt -s cmdhist
shopt -s histappend

export HISTFILESIZE=1000000000
export HISTSIZE=1000000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:ignorespace

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

[ -r ~/.bashrc.local ] && . ~/.bashrc.local

if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

hue_to_ansi256() {
    # map hue (from 0-1536) to saturated ansi256 color
    h=$1

    s=180

    n=$(( ((h)/256)%6 ))

    x=$((h%256))
    y=$((256-x))

    x=$((x*128/256))
    y=$((y*128/256))

    r=$(( (n==0? s   :(n==1? y   :(n==2? 0   :(n==3? 0   :(n==4? x   :(n==5? s   :0)))))) ))
    g=$(( (n==0? x   :(n==1? s   :(n==2? s   :(n==3? y   :(n==4? 0   :(n==5? 0   :0)))))) ))
    b=$(( (n==0? 0   :(n==1? 0   :(n==2? x   :(n==3? s   :(n==4? s   :(n==5? y   :0)))))) ))

    printf "%3d" $(((r<75?0:(r-35)/40)*6*6+(g<75?0:(g-35)/40)*6+(b<75?0:(b-35)/40)+16))
}

if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
    . /usr/lib/git-core/git-sh-prompt
    PS1_GIT="\$(__git_ps1)"
fi

strToColor() {
  echo "$(hue_to_ansi256 $(( $(cksum <<< ${1} | cut -f 1 -d ' ') % 1280 + 128)))"
}

HOST_KEY_COLOR="$(strToColor $(hostname))"

build_prompt() {
  section() {
    FG=$1
    BG=$2

    if [ -n "$PREV_BG" ]; then
      PS1+="\[$(tput setaf $PREV_BG)$(tput setab $BG)\] "
    fi

    PS1+="\[$(tput setaf $FG)$(tput setab $BG)\]$3"

    PREV_BG="$BG"
  }

  PREV_BG=""
  PS1=""

  if [ -n "${TMUX}" ] ; then
      section 255 ${HOST_KEY_COLOR} ""
  else
      section 255 ${HOST_KEY_COLOR} "\u@\h"
  fi

  if [ -n "${VCS}" ]; then
    section 15 245 " ${VCS}"
  fi

  section 15 238 "\W"

  PS1+="\[$(tput sgr0)$(tput setaf $PREV_BG)\]\[$(tput sgr0)\] "
}

PROMPT_COMMAND="build_prompt"
