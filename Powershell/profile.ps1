Import-Module posh-git

Import-Module PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key Ctrl+P -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Ctrl+N -Function NextHistory
Set-PSReadlineKeyHandler -Key Ctrl+G -Function RevertLine

# Would be nice to just disable syntax coloring, now sure how though
Set-PSReadlineOption -ForegroundColor White -TokenKind Command
Set-PSReadlineOption -ForegroundColor White -TokenKind Keyword
Set-PSReadlineOption -ForegroundColor White -TokenKind None
Set-PSReadlineOption -ForegroundColor White -TokenKind Operator
Set-PSReadlineOption -ForegroundColor White -TokenKind String
Set-PSReadlineOption -ForegroundColor White -TokenKind Variable
Set-PSReadlineOption -ForegroundColor White -TokenKind Comment
Set-PSReadlineOption -ForegroundColor White -TokenKind Member
Set-PSReadlineOption -ForegroundColor White -TokenKind Number
Set-PSReadlineOption -ForegroundColor White -TokenKind Parameter
Set-PSReadlineOption -ForegroundColor White -TokenKind Type

function Test-Admin
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE
    Write-Host ("[") -nonewline -foregroundcolor DarkGray
    Write-Host ([Environment]::UserName) -nonewline -foregroundcolor Gray
    if ( Test-Admin ) {
        Write-Host -NoNewLine -f red "+Admin"
    }
    if ( $env:VisualStudioVersion ) {
        Write-Host -NoNewLine -f Gray "+VS$env:VisualStudioVersion"
    }
    Write-Host ("@") -nonewline -foregroundcolor DarkGray
    Write-Host ([System.Net.Dns]::GetHostName()) -nonewline -foregroundcolor Gray
    Write-Host (":") -nonewline -foregroundcolor DarkGray
    Write-Host (Split-Path $pwd.ProviderPath -leaf) -nonewline -foregroundcolor White
    Write-VcsStatus
    Write-Host ("]") -nonewline -foregroundcolor DarkGray
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "% "
}


function time {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $args
    $sw.Stop()
    $sw.Elapsed
}

function env {Get-ChildItem Env:}
Set-Alias wc Measure-Object
Set-Alias open Invoke-Item

function emacs {emacsclientw -na runemacs $args}
Set-Alias e "emacs"

function cygwin {C:\cygwin64\bin\zsh.exe}

# posh-git
Enable-GitColors


#Start-SshAgent -Quiet

New-PSDrive p filesystem (Join-Path $env:USERPROFILE projects) *>$null

Set-Alias vs Import-VisualStudioVars