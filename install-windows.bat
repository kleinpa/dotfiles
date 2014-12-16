rem @echo off

rem Emacs
rd /s /q "%USERPROFILE%\AppData\Roaming\.emacs.d"
mklink /d "%USERPROFILE%\AppData\Roaming\.emacs.d" "%~dp0emacs.d"

rem Git
del /f /q "%USERPROFILE%\.gitignore.global"
mklink "%USERPROFILE%\.gitignore.global" "%~dp0gitignore.global"
del /f /q "%USERPROFILE%\.gitconfig"
mklink "%USERPROFILE%\.gitconfig" "%~dp0gitconfig"

rem Vagrant
mkdir "%USERPROFILE%\.vagrant.d\Vagrantfile"
del /f /q "%USERPROFILE%\.vagrant.d\Vagrantfile"
mklink "%USERPROFILE%\.vagrant.d\Vagrantfile" "%~dp0vagrant.d\Vagrantfile"
rd /S /q "%USERPROFILE%\.vagrant.d\scripts"
mklink /d "%USERPROFILE%\.vagrant.d\scripts" "%~dp0vagrant.d\scripts"

rem Putty
regedit /s "%~dp0\putty_default_settings.reg"

rem DiffMerge
regedit /s "%~dp0\diffmerge_settings.reg"

rem Sublime Text 3
mkdir "%USERPROFILE%\AppData\Roaming\Sublime Text 3\Packages"
rd /s /q "%USERPROFILE%\AppData\Roaming\Sublime Text 3\Packages\User"
mklink /d "%USERPROFILE%\AppData\Roaming\Sublime Text 3\Packages\User" "%~dp0Sublime Text"

rem Powershell
mkdir "%USERPROFILE%\Documents\WindowsPowerShell\"
del /f /q "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
mklink "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "%~dp0Powershell\profile.ps1"
rd /s /q "%USERPROFILE%\Documents\WindowsPowerShell\Modules"
mklink /d "%USERPROFILE%\Documents\WindowsPowerShell\Modules" "%~dp0Powershell\Modules"
"%~dp0Powershell\setup.bat"

PAUSE
