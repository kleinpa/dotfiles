#!/bin/bash
FILES="
.zshrc
.zsh
.vimrc
.vim
.gitconfig
.minttyrc
.emacs
.emacs.d
"

for f in $FILES
do
    ln -fs $(realpath `dirname $0`)/$f ~
done

# Set up chere
chere -i -c -f -t mintty -e "Open zsh"

# There should be a better way to do this (set zsh in /etc/passwd)
sed -i -e 's/\(pklein.*\:).*/\1\/bin\/zsh/g' /etc/passwd
