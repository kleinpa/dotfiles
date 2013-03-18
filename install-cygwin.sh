#!/bin/bash
FILES="
zshrc
zsh
vimrc
vim
gitconfig
gitignore.global
minttyrc
emacs.d
"

#for f in $FILES
#do
#    ln -fs $(realpath `dirname $0`)/$f ~
#done


ln -fs $(realpath `dirname $0`)/zshrc ~/.zshrc
ln -fs $(realpath `dirname $0`)/zsh ~/.zsh
ln -fs $(realpath `dirname $0`)/vimrc ~/.vimrc
ln -fs $(realpath `dirname $0`)/gitconfig ~/.gitconfig
ln -fs $(realpath `dirname $0`)/gitignore.global ~/.gitignore.global
ln -fs $(realpath `dirname $0`)/minttyrc ~/.minttyrc
ln -fs $(realpath `dirname $0`)/emacs.d ~/.emacs.d

# Set up chere
chere -i -c -f -t mintty -e "Open zsh"

# There should be a better way to do this (set zsh in /etc/passwd)
sed -i -e 's/\(pklein.*\:).*/\1\/bin\/zsh/g' /etc/passwd
