dotfiles
========

A collection of config files I'd like to keep in sync between machines.

The `dotfiles` directory can live anywhere, the installers will automatically symlink the dotfiles into the proper directories.

## Installation
### Linux
```sh
cd dotfiles
./install-linux.sh
```

Confiugring under cygwin is similar but uses install-cygwin instead.

### Windows
Run `install-windows.sh`

Note that in Windows 8 the script seems to only work when run as administrator.

## Contents
             | Linux  | Cygwin  | Windows | Notes
-------------|:------:|:-------:|:-------:|---------------------------
Awesome      | ✓      |         |         |
Emacs        | ✓      | ✓       | ✓       |
Git          | ✓      | ✓       | ✓       |
MinTTY       | ✓      |         |         |
Putty        |        |         | ✓       | Installs via registry key
Sublime Text | ✓      |         | ✓       |
Vim          | ✓      | ✓       | ✓       |
Wallpaper    | ✓      | ✓       | ✓       |
xinit        | ✓      | ✓       | ✓       |
Xresources   | ✓      | ✓       |         |
Zsh          | ✓      | ✓       |         |