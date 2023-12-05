#!/bin/bash -ue
cd $(dirname $0)

# These files are directly linked in from the repository. The link source is the
# file but without the first dot.

LINK=(
    bash_profile
    bashrc
    bashrc.d/aliases
    bashrc.d/common
    bashrc.d/history
    bashrc.d/path
    bashrc.d/prompt
    bin/sshtm
    bin/hash_color
    emacs.d/init.el
    emacs.d/lisp
    gitconfig
    gitignore.global
    inputrc
    profile
    ssh/config
    tmux.conf
    vimrc
)

command -v realpath >/dev/null 2>&1 || {
  echo "This script requires the program 'realpath', aborting." 1>&2;
  exit 1;
}

log () {
    echo "$(git config --get remote.origin.url):" $@ >&2
}

for src in ${LINK[@]} ; do
    src=$(realpath $src)
  if [ ! -r $src ]; then log "can not read source file $src"; exit 1; fi
done

for src in ${LINK[@]} ; do
    # Add a '.' prefix to the link destination
    dst=$HOME/.$(realpath --relative-to=$(pwd) $src)
    src=$(realpath $src)

    mkdir -p $(dirname $dst)
    [ "$src" -ef "$dst" ] || ln -nfs $src $dst
    log "~/$(realpath -s --relative-to=$HOME $dst) -> $(readlink $dst)"
done

# Miscellaneous

touch $HOME/.hushlogin
log "~/.hushlogin (empty)"

