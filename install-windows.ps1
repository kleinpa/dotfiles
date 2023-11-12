[CmdletBinding()]
Param(
    [string[]] $Configs = @("All")
)

$ErrorActionPreference = "Stop"

function Make-Directory($Path) {
    New-Item -Force -ItemType directory -Path $Path 
}

function Delete($Path) {
    if (Test-Path $Path) {
        Remove-Item -Recurse $Path
    }
}

Function New-SymLink ($Link, $Target) {
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target
}

$UserProfile = [environment]::getFolderPath("UserProfile")
$ApplicationData = [environment]::getFolderPath("ApplicationData")

# if("Emacs" -in $Configs -Or "All" -in $Configs) {
#     Make-Directory "${ApplicationData}\.emacs.d"
#     Delete "${ApplicationData}\.emacs.d\init.el"
#     New-SymLink "${ApplicationData}\.emacs.d\init.el" "${PSScriptRoot}\emacs.d\init.el"
#     New-SymLink "${ApplicationData}\.emacs.d\lisp" "${PSScriptRoot}\emacs.d\lisp"
# }

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

if("Powershell" -in $Configs -Or "All" -in $Configs) {
    # Make-Directory "${UserProfile}\Documents\WindowsPowerShell\"
    # Delete "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    # New-SymLink "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "${PSScriptRoot}\Powershell\profile.ps1"
    # rd /s /q "${UserProfile}\Documents\WindowsPowerShell\Modules"
    # New-SymLink /d "${UserProfile}\Documents\WindowsPowerShell\Modules" "${PSScriptRoot}\Powershell\Modules"
    # "${PSScriptRoot}\Powershell\setup.bat"
}

# if("WSL" -in $Configs -Or "All" -in $Configs) {
#     if (Get-Command "bash.exe" -ErrorAction SilentlyContinue)
#     {
#         $WSLHome = $(Invoke-Command {cd ~; bash -c pwd})
#         Push-Location "${PSScriptRoot}"
#         bash.exe -c "ln -s ${WSLHome}/Projects ~/projects"
#         bash.exe -c "~/projects/dotfiles/install-linux.sh"
#         Pop-Location
#     }
# }
