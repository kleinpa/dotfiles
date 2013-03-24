@echo off
rd /S /Q "%USERPROFILE%\vimfiles"
mklink /D "%USERPROFILE%\vimfiles" "%~dp0vim"
del /F /Q "%USERPROFILE%\_vimrc"
mklink "%USERPROFILE%\_vimrc" "%~dp0vimrc"
del /F /Q "%USERPROFILE%\AppData\Roaming\.emacs.d"
mklink /D "%USERPROFILE%\AppData\Roaming\.emacs.d" "%~dp0emacs.d"
del /F /Q "%USERPROFILE%\.gitignore.global"
mklink "%USERPROFILE%\.gitignore.global" "%~dp0gitignore.global"
del /F /Q "%USERPROFILE%\.gitconfig"
mklink "%USERPROFILE%\.gitconfig" "%~dp0gitconfig"

regedit /s "%~dp0\putty_default_settings.reg"

