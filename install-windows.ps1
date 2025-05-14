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
        Write-Warning "Deleting $Path"
        Remove-Item -Recurse $Path
    }
}

Function New-SymLink ($Link, $Target) {
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target
}

$UserProfile = [environment]::getFolderPath("UserProfile")

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
    Make-Directory "${UserProfile}\Documents\WindowsPowerShell\"
    Delete "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    New-SymLink "${UserProfile}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "${PSScriptRoot}\Powershell\profile.ps1"
    "${PSScriptRoot}\Powershell\setup.bat"
}

