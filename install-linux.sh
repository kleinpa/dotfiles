#!/usr/bin/env bash
set -e

command -v realpath >/dev/null 2>&1 || {
  echo "This script requires the program 'realpath', aborting.";
  exit 1;
}

BASIC_LINK=(
    bash_profile
    bashrc
    bashrc.d/aliases
    bashrc.d/common
    bashrc.d/history
    bashrc.d/prompt
    bin
    emacs.d/init.el
    emacs.d/lisp
    gitconfig
    gitignore.global
    inputrc
    minttyrc
    profile
    ssh/config
    tmux.conf
    vimrc
    xinitrc
    Xresources
    Xresources
    zprofile
    zsh
    zshrc
)

for f in ${BASIC_LINK[@]}; do
    [ -d "$(dirname ~/.${f})" ] || mkdir -p "$(dirname ~/.${f})"
    ln -Tfs "$(realpath `dirname $0`)/${f}" "$HOME/.${f}"
    echo "Linked .${f}"
done

touch ~/.hushlogin
mkdir -p ~/.config
