# if (Get-Command "git.exe" -ErrorAction SilentlyContinue)
# {
#     if (Get-Module -ListAvailable -Name posh-git) {
#         Import-Module posh-git
#         Enable-GitColors
#     }
# }

if ($PSVersionTable.PSVersion.Major -ge 3)
{
    Import-Module PSReadline
    Set-PSReadlineOption -EditMode Emacs
    Set-PSReadlineKeyHandler -Key Ctrl+P -Function PreviousHistory
    Set-PSReadlineKeyHandler -Key Ctrl+N -Function NextHistory
    Set-PSReadlineKeyHandler -Key Ctrl+G -Function RevertLine
    Set-PSReadlineKeyHandler -Key Ctrl+Backspace -Function KillWord
    Set-PSReadlineKeyHandler -Key Ctrl+Shift+Backspace -Function KillWord
    Set-PSReadlineKeyHandler -Key Shift+Backspace -Function KillWord
}

function Test-Admin
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE
    # Notify-Done(Get-History -count 1)
    # Write-Host ("[") -NoNewline -foregroundcolor DarkGray
    if (Test-Admin)
    {
	    Write-Host  -ForegroundColor Red ([Environment]::UserName) -NoNewline
    }
    else
    {
        Write-Host  -ForegroundColor White ([Environment]::UserName) -NoNewline
    }
    # if ($env:VisualStudioVersion)
    # {
    #     Write-Host -NoNewline -f Gray "+VS$env:VisualStudioVersion"
    # }
    Write-Host -ForegroundColor White ("@") -NoNewline
    Write-Host -ForegroundColor White  ([System.Net.Dns]::GetHostName()) -NoNewline 
    Write-Host -ForegroundColor Gray  (" ") -NoNewline 
    Write-Host -ForegroundColor Gray  (Split-Path $pwd.ProviderPath -leaf) -NoNewline 
    Write-Host -ForegroundColor Gray  (" ") -NoNewline
    # if (Get-Command Write-VcsStatus -ErrorAction SilentlyContinue)
    # {
    #     Write-VcsStatus
    # }
    # Write-Host ("]") -NoNewline -ForegroundColor DarkGray
    $global:LASTEXITCODE = $realLASTEXITCODE
    if (Test-Admin)
    {
        return "# "
    }
    else
    {
        return "> "
    }
}

# function time
# {
#     $sw = [Diagnostics.Stopwatch]::StartNew()
#     $args
#     $sw.Stop()
#     $sw.Elapsed
# }

# function env
# {
#     Get-ChildItem Env:
# }

# Set-Alias wc Measure-Object

# if (Test-Path (Join-Path $env:USERPROFILE projects))
# {
#     New-PSDrive p filesystem (Join-Path $env:USERPROFILE projects) *>$null
# }

# function which ([string] $cmd) {
#     $path = (Get-Command $cmd).Path
# }
