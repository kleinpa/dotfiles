
ln -Tfs $(realpath `dirname $0`)/zshrc ~/.zshrc
ln -Tfs $(realpath `dirname $0`)/zsh ~/.zsh
ln -Tfs $(realpath `dirname $0`)/vimrc ~/.vimrc
ln -Tfs $(realpath `dirname $0`)/gitconfig ~/.gitconfig
ln -Tfs $(realpath `dirname $0`)/gitignore.global ~/.gitignore.global
ln -Tfs $(realpath `dirname $0`)/minttyrc ~/.minttyrc
ln -Tfs $(realpath `dirname $0`)/emacs.d ~/.emacs.d
ln -Tfs $(realpath `dirname $0`)/Xresources ~/.Xresources
ln -Tfs $(realpath `dirname $0`)/xinitrc ~/.xinitrc
ln -Tfs $(realpath `dirname $0`)/awesome ~/.config/awesome
ln -Tfs "$(realpath `dirname $0`)/Sublime Text" ~/.config/sublime-text-3/Packages
ln -Tfs $(realpath `dirname $0`)/profile ~/.profile
ln -Tfs $(realpath `dirname $0`)/zprofile ~/.zprofile
ln -Tfs $(realpath `dirname $0`)/ssh/config ~/.ssh/config
ln -Tfs $(realpath `dirname $0`)/bin ~/bin

mkdir -p ~/.vagrant.d/
ln -Tfs $(realpath `dirname $0`)/vagrant.d/Vagrantfile ~/.vagrant.d/Vagrantfile
ln -Tfs $(realpath `dirname $0`)/vagrant.d/scripts ~/.vagrant.d/scripts
