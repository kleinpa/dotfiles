#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
apt-get update > /dev/null
apt-get -y install zsh git-core realpath
sudo chsh vagrant -s /bin/zsh

su vagrant << SCRIPT
  if [[ -a .ssh && ! -L .ssh ]]; then
    cp -rf .ssh -T .ssh.orig
  fi
  touch ~/.hushlogin
  echo "C1=$'%{\e[1;35m%}'">~/.zshrc.local
  rm -rf ~/.dotfiles
  git clone http://github.com/kleinpa/dotfiles.git ~/.dotfiles
  mv ~/.profile ~/.profile.local -f

  rm -rf ~/.ssh
  ~/.dotfiles/install-linux.sh
  ln -sf ~/.ssh.orig/* -t ~/.ssh

SCRIPT
