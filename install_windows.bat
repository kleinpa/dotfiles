rem echo " The following lines added by %~dp0\install_windows.bat >> %USERPROFILE%\_vimrc
rem echo set runtimepath=%~dp0.vim,$VIM,$VIMRUNTIME >> %USERPROFILE%\_vimrc
rem echo so %~dp0.vimrc >> %USERPROFILE%\_vimrc
@echo off
rd /S /Q %USERPROFILE%\vimfiles
mklink /D %USERPROFILE%\vimfiles %~dp0.vim
del /F %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %~dp0.vimrc
del /F %USERPROFILE%\.emacs
mklink %USERPROFILE%\.emacs %~dp0.emacs
del /F %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %~dp0.gitconfig

regedit /s %~dp0\putty_default_settings.reg
