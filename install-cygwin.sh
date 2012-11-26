#!/bin/bash
FILES="
.zshrc
.zsh
.vimrc
.vim
.gitconfig
.minttyrc
"

for f in $FILES
do
    ln -fs `dirname $0`/$f ~
done
