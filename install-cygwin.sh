#!/bin/bash
FILES="
.zshrc
.zsh
.vimrc
.vim
.gitconfig
.minttyrc
.emacs
"

for f in $FILES
do
    ln -fs $(realpath `dirname $0`)/$f ~
done
