#########################################################
#                         prompt                         #
#########################################################
setprompt () {
    # Need this so the prompt will work.
    setopt prompt_subst
    
    # simple version of my ZSH prompt
    #RPROMPT=''
    PROMPT='[%n@%m %c]%# '
    C0=$'%{\e[1;33m%}'     # White for [ : ] 
    C1=$'%{\e[1;31m%}'     # Color for name, system, directory
    C2=$'%{\e[0m%}'        # Color for averything after prompt

#    PROMPT=$'[\e[0;31m%n@%m\e[0m:\e[0;31m%c\e[0m%}]%# '
    PROMPT='$C0%}[$C1%n$C0@$C1%m$C0:$C1%c$C0]$C2%# '
#    PROMPT='i.$C0.[%n@%m %c]%# '
    PS2=''
}

setprompt

#########################################################
#                      commonfunc                       #
#########################################################

UNAME=$(uname)

makeMeLaugh() {
  if checkPath fortune; then
    local FORTUNE
    if [ -d /opt/local/share/games/fortune/comedy ] || [ -d /usr/share/games/fortune/comedy ]; then
        FORTUNE=$(fortune -e comedy)
    else
        FORTUNE=$(fortune -a)
    fi
    echo -e "\n$FORTUNE\n"
  fi
}

# helper function to search the $PATH for a given
# executable.  useful for checks across different
# systems.
checkPath() {
    local execpath
    local OIFS
    # the bash compatible version of this
    OIFS=$IFS
    IFS=':'
    for dir in $PATH
    do 
        execpath="$dir/$1" 
        if [ -x $execpath ]; then
            IFS=$OIFS
            return 0
        fi
    done

    # set the file separator back to normal
    IFS=$OIFS
    
    # the zsh compatible version
    for dir in $path
    do 
        execpath="$dir/$1"
        if [ -x $execpath ]; then
            return 0
        fi
    done
    
    return 1
}

isiPhone() {
    if checkPath sw_vers; then
        [ $(sw_vers | awk '/ProductName/ {print $2}') = "iPhone" ] && return 0
    fi
    return 1
}

# a little function to print the full path to a file.
fullpath() {
    local fullpath
    fullpath=$(pwd)/$1
    echo $fullpath
    
    # on OS X copy it to the clipboard too :)
    if checkPath pbcopy && [ $UNAME = "Darwin" ]; then
        echo $fullpath | pbcopy
    fi
}

#########################################################
#                      commonrc                         #
#########################################################
# re link all the conf files
alias qs='~/.dotfiles/create_links.sh'

# shortcut for long descrip checking
alias py_long_descrip="python2.4 setup.py --long-description"
# use cat to show the file
alias descrip_check="py_long_descrip > /tmp/package.rst && rst2html.py /tmp/package.rst /tmp/package.html && cat -n /tmp/package.rst"

# some OS X specific stuff
##########################
if [[ $UNAME == "Darwin" ]]; then
    
    # set up a path in .profile for TextMate (zsh haterz)
    echo "export PATH=$PATH" > $HOME/.profile

    # Helpers to see if a python package's long descrip is proper...
    alias descrip_check="py_long_descrip > /tmp/package.rst && rst2html.py /tmp/package.rst /tmp/package.html && mate /tmp/package.rst"
    # run the setup.py descrip through docutils, then open it with the default browser
    alias descrip_check_open="py_long_descrip | rst2html.py > /tmp/foo.html && open file:///tmp/foo.html"

    # iPhone doesn't have a defaults command...yet
    if checkPath defaults; then
        # also set up the osx path
        # (this will overwrite the PATH everytime we open a shell)
        defaults write $HOME/.MacOSX/environment PATH -string $PATH
    fi

    # add ports into the $MANPATH
    export MANPATH=/opt/local/man:$MANPATH
fi

# processes
###########
# output more lines so that you can grep them
alias psa='ps axwww'
# grep through processes
alias psg='psa | grep -i'

# svn helpers
#############
#alias svnps="svn propset svn:externals -F EXTERNALS.txt ."
#alias svnpsi="svn propset svn:ignore -F IGNORE.txt ."

# zope runs most QA/Staging instances...
#alias zu='sudo -H -u zope'

# buildout...
#############
#alias bfg='bin/control fg'
#alias bs='bin/control stop'
#alias bbn='bin/buildout -v'

# make copy and move ask before replacing files
alias cp='cp -i'
alias mv='mv -i'

# ls aliases
############
# conditionally set up coloring on different OS types
if [ $UNAME = "FreeBSD" ] || [ $UNAME = "Darwin" ]; then
   alias ls="ls -GF"
elif [ $UNAME = "Linux" ]; then
   alias ls="ls --color=auto -F"
elif [ $UNAME = 'SunOS' ]; then
   alias ls="ls --color=always -F"
fi

# show me everything
alias ll='ls -al'
# sort by size
alias lss='ll -Sr'
# ll but human readable size
alias lsa='ll -h'
# show all dot files and dirs
#alias lsd='ls -ld .*'

# less
######

# case insensetive searching in less
alias less='less -I'

# tar
#####
# create a tgz archive ignoring some files
#alias targzc='tar --exclude=".DS_Store" --exclude="*pyc" -zcvf'
# create a tbz2 archive ignoring some files
#alias tarbzc='tar --exclude=".DS_Store" --exclude="*pyc" -jcvf'
# unarchive
#alias targzx='tar -zxvf'
#alias tarbzx='tar -xvjf'

# always show all versions of an executable
#alias which="which -a"

# colors!!!
###########

# for FreeBSD
# Pretty LSCOLORS explanation:
# http://www.mjxg.com/index.py/geek/lscolors_and_ls_colors
#
# This set works nicely for dark backgrounds...
#
#export LSCOLORS="cxgxCxdxbxegedabagacdx"

# for linux
# Pretty LS_COLORS explanation: 
# http://www.mjxg.com/index.py/geek/lscolors_and_ls_colors
#
# This set works nicely for dark backgrounds...
#
#export LS_COLORS="no=00:fi=00:di=32:ln=36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=31:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:"

# set the ACK match color scheme
#export ACK_COLOR_MATCH="red"

# set the grep colors for matching, etc.
#export GREP_COLORS="ms=01;31:mc=01;31:sl=:cx=:fn=32:ln=36:bn=32:se=39"


#########################################################
#                         zshrc                         #
#########################################################

# Common hashes
#hash -d L=/var/log
#hash -d R=/usr/local/etc/rc.d

# OS X specific settings
if [ $UNAME = "Darwin" ]; then
    
    # set up dir hashes
    #hash -d P=$HOME/sixfeetup/projects
    #hash -d S=$HOME/Sites

fi

# global aliases
################
# disable the plonesite part in a buildout run, example: $ bin/buildout -N psef
#alias -g psef="plonesite:enabled=false"
# get the site packages for your python, example: $ cd $(python2.5 site-packages)
#alias -g site_packages='-c "from distutils.sysconfig import get_python_lib; print get_python_lib()"'

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

# uncomment this to show when you aren't the current user
ME="kleinpa"

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

