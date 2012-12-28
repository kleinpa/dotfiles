@echo off
rd /S /Q "%USERPROFILE%\vimfiles"
mklink /D "%USERPROFILE%\vimfiles" "%~dp0.vim"
del /F "%USERPROFILE%\_vimrc"
mklink "%USERPROFILE%\_vimrc" "%~dp0.vimrc"
del /F C:\.emacs
mklink "%USERPROFILE%\AppData\Roaming\.emacs" "%~dp0.emacs"
mklink /D "%USERPROFILE%\AppData\Roaming\.emacs.d" "%~dp0.emacs.d"
del /F "%USERPROFILE%\.gitconfig"
mklink "%USERPROFILE%\.gitconfig" "%~dp0.gitconfig"

regedit /s "%~dp0\putty_default_settings.reg"

