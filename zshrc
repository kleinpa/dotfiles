# Aliases
#########
alias cp='cp -i'
alias mv='mv -i'

alias ls="ls --color=auto --file-type"
alias ll='ls -ahl'

alias less='less -I'
alias l='less'


alias e='$EDITOR'

hash -d p=~/projects/

# Editors
########

# These represent my current preferences
if [[ -n $(command -v emacs) ]]; then
    export EDITOR=emacs
elif [[ -n $(command -v sublime_text) ]]; then
    export EDITOR=sublime_text
elif [[ -n $(command -v vim) ]]; then
    export EDITOR=vim
elif [[ -n $(command -v nano) ]]; then
    export EDITOR=nano
fi

# vim is nice for editing commits
if [[ -n $(command -v vim) ]]; then
    export GIT_EDITOR="vim -c 'startinsert'"
elif [[ -n $(command -v emacs) ]]; then
    export GIT_EDITOR="emacs -nw"
elif [[ -n $(command -v nano) ]]; then
    export GIT_EDITOR=nano
fi

#########################################################
#                      commonfunc                       #
#########################################################

# for linux
# Pretty LS_COLORS explanation:
# http://www.mjxg.com/index.py/geek/lscolors_and_ls_colors
#
# This set works nicely for dark backgrounds...
#
export LS_COLORS="no=00:fi=00:di=32:ln=36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=31:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:"

# set the grep colors for matching, etc.
export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=32:ln=36:bn=32:se=39"


#########################################################
#                         zshrc                         #
#########################################################

# turn off the stupid bell
#setopt NO_BEEP
# Changing Directories
setopt AUTO_CD CDABLE_VARS
# History
setopt HIST_SAVE_NO_DUPS HIST_VERIFY HIST_IGNORE_ALL_DUPS EXTENDED_HISTORY
# globbing
#setopt GLOB_DOTS

# vi command line editor
########################
#bindkey -v
# use home and end to go to end and beginning of the line
bindkey -M viins '^[[H' vi-beginning-of-line
bindkey -M viins '^[[F' vi-end-of-line
# use ctrl+a and ctrl+e like emacs mode
bindkey -M viins '^A' vi-beginning-of-line
bindkey -M viins '^E' vi-end-of-line
# use delete as forward delete
bindkey -M viins '\e[3~' vi-delete-char
# line buffer
#bindkey -M viins '^B' push-line-or-edit

# History settings
##################
HISTSIZE=300000
SAVEHIST=3000
HISTFILE=~/.zsh_history
export HISTFILE HISTSIZE SAVEHIST

# Completions
#############
autoload -U compinit
compinit -C
# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

if [[ "$TERM" != emacs ]]; then
[[ -z "$terminfo[kdch1]" ]] || bindkey -M emacs "$terminfo[kdch1]" delete-char
[[ -z "$terminfo[khome]" ]] || bindkey -M emacs "$terminfo[khome]" beginning-of-line
[[ -z "$terminfo[kend]" ]] || bindkey -M emacs "$terminfo[kend]" end-of-line
[[ -z "$terminfo[kich1]" ]] || bindkey -M emacs "$terminfo[kich1]" overwrite-mode
[[ -z "$terminfo[kdch1]" ]] || bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
[[ -z "$terminfo[khome]" ]] || bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
[[ -z "$terminfo[kend]" ]] || bindkey -M vicmd "$terminfo[kend]" vi-end-of-line
[[ -z "$terminfo[kich1]" ]] || bindkey -M vicmd "$terminfo[kich1]" overwrite-mode

[[ -z "$terminfo[cuu1]" ]] || bindkey -M viins "$terminfo[cuu1]" vi-up-line-or-history
[[ -z "$terminfo[cuf1]" ]] || bindkey -M viins "$terminfo[cuf1]" vi-forward-char
[[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" vi-up-line-or-history
[[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" vi-down-line-or-history
[[ -z "$terminfo[kcuf1]" ]] || bindkey -M viins "$terminfo[kcuf1]" vi-forward-char
[[ -z "$terminfo[kcub1]" ]] || bindkey -M viins "$terminfo[kcub1]" vi-backward-char

# ncurses fogyatekos
[[ "$terminfo[kcuu1]" == "^[O"* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" vi-up-line-or-history
[[ "$terminfo[kcud1]" == "^[O"* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" vi-down-line-or-history
[[ "$terminfo[kcuf1]" == "^[O"* ]] && bindkey -M viins "${terminfo[kcuf1]/O/[}" vi-forward-char
[[ "$terminfo[kcub1]" == "^[O"* ]] && bindkey -M viins "${terminfo[kcub1]/O/[}" vi-backward-char
[[ "$terminfo[khome]" == "^[O"* ]] && bindkey -M viins "${terminfo[khome]/O/[}" beginning-of-line
[[ "$terminfo[kend]" == "^[O"* ]] && bindkey -M viins "${terminfo[kend]/O/[}" end-of-line
[[ "$terminfo[khome]" == "^[O"* ]] && bindkey -M emacs "${terminfo[khome]/O/[}" beginning-of-line
[[ "$terminfo[kend]" == "^[O"* ]] && bindkey -M emacs "${terminfo[kend]/O/[}" end-of-line
fi

# Autoload zsh functions.
fpath=(~/.zsh/functions $fpath)
autoload -U ~/.zsh/functions/*(:t)

# Git Prompt: http://sebastiancelis.com/2009/11/16/zsh-prompt-git-users/
#############
# Enable auto-execution of functions
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions
preexec_functions+='preexec_update_git_vars'
precmd_functions+='precmd_update_git_vars'
chpwd_functions+='update_current_git_vars'
update_current_git_vars

if command -v virtualenvwrapper.sh >/dev/null 2>/dev/null; then
    source virtualenvwrapper.sh
fi


# Allow subsitutuion in prompt.
setopt prompt_subst

# Color Definitions
# colors       : black red green yellow blue magenta cyan white
# $k %K{color} : background
# $f %F{color} : forground
# %b %B        : bold

C0=$'%{%b%k%F{white}%}'     # White for @ : () %
C1=$'%{%b%k%F{magenta}%}'     # Color for name, system, directory
C2=$'%{%b%k%F{blue}%}'     # Color for GIT info

if [[ -e ~/.zshrc.local ]]; then
   source ~/.zshrc.local
fi

# Set the prompt.
PROMPT='$C1%n$C0@$C1%m$C0:$C1%c$(prompt_git_info)$C0%#%{%b%k%f%} '

if [[ $(uname) = "CYGWIN"* ]]; then
    if [[ -e ~/.zshrc.cygwin ]]; then
	source ~/.zshrc.cygwin
    fi
fi

[[ $EMACS = t ]] && unsetopt zle

export TERM=xterm-256color