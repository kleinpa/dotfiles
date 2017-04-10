export HTML_TIDY=~/.tidy
export LESS=-iXR
export PATH=$HOME/bin:$PATH
export PS1='\h:\w\$ '
export RSYNC_RSH=ssh
export EDITOR="/Applications64/Emacs/bin/emacsclient -na \"C:\Program Files\Emacs\bin\runemacs.exe\""

alias cp='cp -i'
alias mv='mv -i'
alias ls="ls --color=auto --file-type"
alias less='less -I'

alias e='$EDITOR'

hash -d p=~/projects/


alias emacs="/Applications64/Emacs/bin/emacsclient -na \"C:\Program Files\Emacs\bin\runemacs.exe\""
alias ls="ls --file-type --color=auto"
alias ll="ls -al"
alias open=cygstart
alias c=""

shopt -s nocaseglob
umask 022

C0="\[\033[1;37m\]"     # White for @ : () %
C1="\[\033[1;35m\]"     # Color for name, system, directory
C2="\[\033[1;34m\]"     # Color for GIT info


if [[ -e ~/.bashrc.local ]]; then
   source ~/.bashrc.local
fi


# Set the prompt.
PS1="${C1}\u${C0}@${C1}\h${C0}:${C1}\w${C0}\[\033[0m\]\$ "
