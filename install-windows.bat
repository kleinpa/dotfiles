@echo off
rd /S /Q %USERPROFILE%\vimfiles
mklink /D %USERPROFILE%\vimfiles %~dp0.vim
del /F %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %~dp0.vimrc
del /F C:\.emacs
mklink C:\.emacs %~dp0.emacs
del /F %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %~dp0.gitconfig

regedit /s %~dp0\putty_default_settings.reg
