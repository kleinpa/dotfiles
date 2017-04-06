command -v realpath >/dev/null 2>&1 || {
  echo "This script requires the program 'realpath', aborting.";
  exit 1;
}

ln -Tfs "$(realpath `dirname $0`)/zshrc" ~/.zshrc
ln -Tfs "$(realpath `dirname $0`)/zsh" ~/.zsh
ln -Tfs "$(realpath `dirname $0`)/bashrc" ~/.bashrc
ln -Tfs "$(realpath `dirname $0`)/bash_profile" ~/.bash_profile
ln -Tfs "$(realpath `dirname $0`)/vimrc" ~/.vimrc
ln -Tfs "$(realpath `dirname $0`)/gitconfig" ~/.gitconfig
ln -Tfs "$(realpath `dirname $0`)/gitignore.global" ~/.gitignore.global
ln -Tfs "$(realpath `dirname $0`)/minttyrc" ~/.minttyrc
ln -Tfs "$(realpath `dirname $0`)/Xresources" ~/.Xresources
ln -Tfs "$(realpath `dirname $0`)/xinitrc" ~/.xinitrc
ln -Tfs "$(realpath `dirname $0`)/profile" ~/.profile
ln -Tfs "$(realpath `dirname $0`)/zprofile" ~/.zprofile

mkdir -p ~/.ssh
ln -Tfs "$(realpath `dirname $0`)/ssh/config" ~/.ssh/config

mkdir -p ~/.emacs.d
ln -Tfs "$(realpath `dirname $0`)/emacs.d/init.el" ~/.emacs.d/init.el

mkdir -p ~/.config
ln -Tfs "$(realpath `dirname $0`)/awesome" ~/.config/awesome

mkdir -p ~/.config/sublime-text-3
ln -Tfs "$(realpath `dirname $0`)/Sublime Text" ~/.config/sublime-text-3/Packages

touch ~/.hushlogin
