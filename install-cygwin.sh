`dirname $0`/install-linux.sh
ln -Tfs $(realpath `dirname $0`)/zshrc.cygwin ~/.zshrc.cygwin

# There should be a better way to do this (set zsh in /etc/passwd)
sed -i -e "s/\(`whoami`.*\:\).*/\1\/bin\/zsh/g" /etc/passwd
