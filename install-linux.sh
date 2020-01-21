#!/bin/bash -ue

# These files are directly linked in from the repository. The link source is the
# file but without the first dot.

BASIC_LINK=(
    .bash_profile
    .bashrc
    .bashrc.d/aliases
    .bashrc.d/common
    .bashrc.d/history
    .bashrc.d/prompt
    .bin/hash_color
    .emacs.d/init.el
    .emacs.d/lisp
    .gitconfig
    .gitignore.global
    .inputrc
    .minttyrc
    .profile
    .ssh/config
    .tmux.conf
    .vimrc
    .xinitrc
    .Xresources
    .Xresources
    .zprofile
    .zsh
    .zshrc
)

command -v realpath >/dev/null 2>&1 || {
  echo "This script requires the program 'realpath', aborting." 1>&2;
  exit 1;
}

SOURCE="$(realpath $(dirname $0))"

# Check that all link source files exist
for f in ${BASIC_LINK[@]}; do
  if [[ ! -r "${SOURCE}/${f##.}" ]]; then
    echo "Source file for '${f}' does not exist in this directory" 1>&2
    exit 1
  fi
done

for f in ${BASIC_LINK[@]}; do
  echo "Linking ${f}" 1>&2
  [[ -d "$(dirname ~/${f})" ]] || mkdir -p "$(dirname ~/${f})"
  ln -Tfs "${SOURCE}/${f##.}" "$HOME/${f}"
done

# Miscellaneous

echo "Creating empty ~/.hushlogin" 1>&2
touch "${HOME}/.hushlogin"
