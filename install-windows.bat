@echo off
del /F /Q "%USERPROFILE%\AppData\Roaming\.emacs.d"
mklink /D "%USERPROFILE%\AppData\Roaming\.emacs.d" "%~dp0emacs.d"
del /F /Q "%USERPROFILE%\.gitignore.global"
mklink "%USERPROFILE%\.gitignore.global" "%~dp0gitignore.global"
del /F /Q "%USERPROFILE%\.gitconfig"
mklink "%USERPROFILE%\.gitconfig" "%~dp0gitconfig"

del /F /Q "%USERPROFILE%\.vagrant.d\Vagrantfile"
mklink "%USERPROFILE%\.vagrant.d\Vagrantfile" "%~dp0vagrant.d\Vagrantfile"
del /F /Q "%USERPROFILE%\.vagrant.d\scripts"
mklink /D "%USERPROFILE%\.vagrant.d\scripts" "%~dp0vagrant.d\scripts"

regedit /s "%~dp0\putty_default_settings.reg"
regedit /s "%~dp0\diffmerge_settings.reg"
