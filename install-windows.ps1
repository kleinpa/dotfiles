[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string[]] $Configs = @("All")
)

function Make-Directory($Path) {
    New-Item -Force -ItemType directory -Path $Path | Out-Null
}

function Delete($Path) {
    if (Test-Path $Path) {
        Remove-Item -Recurse $Path
    }
}

Function New-SymLink ($Link, $Target) {
    if (Test-Path -pathType container $Target) {
        Invoke-Expression "cmd /c mklink /d `"$Link`" `"$Target`""
    } else {
        Invoke-Expression "cmd /c mklink `"$Link`" `"$Target `""
    }
}

$UserProfile = [environment]::getFolderPath("UserProfile")
$ApplicationData = [environment]::getFolderPath("ApplicationData")

if("Emacs" -in $Configs -Or "All" -in $Configs) {
    Make-Directory "${ApplicationData}\.emacs.d"
    Delete "${ApplicationData}\.emacs.d\init.el"
    New-SymLink "${ApplicationData}\.emacs.d\init.el" "${PSScriptRoot}\emacs.d\init.el"
    New-SymLink "${ApplicationData}\.emacs.d\lisp" "${PSScriptRoot}\emacs.d\lisp"
}

if("Git" -in $Configs -Or "All" -in $Configs) {
    Delete "${UserProfile}\.gitignore.global"
    New-SymLink "${UserProfile}\.gitignore.global" "${PSScriptRoot}\gitignore.global"
    Delete "${UserProfile}\.gitconfig"
    New-SymLink "${UserProfile}\.gitconfig" "${PSScriptRoot}\gitconfig"
}

if("ssh" -in $Configs -Or "All" -in $Configs) {
    Make-Directory "${UserProfile}\.ssh\"
    Delete "${UserProfile}\.ssh\config"
    New-SymLink "${UserProfile}\.ssh\config" "${PSScriptRoot}\ssh\config"
}

if("Putty" -in $Configs -Or "All" -in $Configs) {
    regedit /s "${PSScriptRoot}\\putty_default_settings.reg"
}

if("DiffMerge" -in $Configs -Or "All" -in $Configs) {
    regedit /s "${PSScriptRoot}\\diffmerge_settings.reg"
}

if("Sublime" -in $Configs -Or "All" -in $Configs) {
    Make-Directory "${ApplicationData}\Sublime Text 3\Packages"
    rd /s /q "${ApplicationData}\Sublime Text 3\Packages\User"
    New-SymLink /d "${ApplicationData}\Sublime Text 3\Packages\User" "${PSScriptRoot}\Sublime Text"
}

if("Atom" -in $Configs -Or "All" -in $Configs) {
    rd /S /q "${UserProfile}\.atom"
    New-SymLink /d "${UserProfile}\.atom" "${PSScriptRoot}\atom"
}

if("Powershell" -in $Configs -Or "All" -in $Configs) {
    Make-Directory "${UserProfile}\Documents\WindowsPowerShell\"
    Delete "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    New-SymLink "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "${PSScriptRoot}\Powershell\profile.ps1"
    rd /s /q "${UserProfile}\Documents\WindowsPowerShell\Modules"
    New-SymLink /d "${UserProfile}\Documents\WindowsPowerShell\Modules" "${PSScriptRoot}\Powershell\Modules"
    "${PSScriptRoot}\Powershell\setup.bat"
}

if("WSL" -in $Configs -Or "All" -in $Configs) {
    if (Get-Command "bash.exe" -ErrorAction SilentlyContinue)
    {
        $WSLHome = $(Invoke-Command {cd ~; bash -c pwd})
        Push-Location "${PSScriptRoot}"
        bash.exe -c "ln -s ${WSLHome}/Projects ~/projects"
        bash.exe -c "~/projects/dotfiles/install-linux.sh"
        Pop-Location
    }
}
