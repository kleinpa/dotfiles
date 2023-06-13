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

    # Would be nice to just disable syntax coloring, now sure how though
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Command
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Keyword
    # Set-PSReadlineOption -ForegroundColor White -TokenKind None
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Operator
    # Set-PSReadlineOption -ForegroundColor White -TokenKind String
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Variable
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Comment
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Member
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Number
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Parameter
    # Set-PSReadlineOption -ForegroundColor White -TokenKind Type
}

function Test-Admin
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# function Notify-Done
# {
#     if($Args[0] -like "c make*")
#     {
# 	$_song = Join-Path (Join-Path ($PSScriptRoot) "Modules") "done.wav"
# 	Add-Type -AssemblyName PresentationCore
# 	$_MediaPlayer = New-Object System.Windows.Media.MediaPlayer
# 	$_MediaPlayer.Open($_song)
# 	$_MediaPlayer.Volume = 1
# 	$_MediaPlayer.Play()
#     }
# }

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
# Set-Alias open Invoke-Item

# function emacs
# {
#     $TEMP_HOME=$Env:HOME
#     Remove-Item Env:HOME
#     If(!$Args)
#     {
#         emacsclientw -na runemacs (Get-Item $Pwd).FullName
#     }
#     else
#     {
#         emacsclientw -na runemacs (Get-Item $Args).FullName
#     }
#     $Env:HOME=$TEMP_HOME
# }
# Set-Alias e "emacs"

# function cygwin {C:\cygwin64\bin\zsh.exe}

# if (Test-Path (Join-Path $env:USERPROFILE projects))
# {
#     New-PSDrive p filesystem (Join-Path $env:USERPROFILE projects) *>$null
# }

# Set-Alias vs Import-VisualStudioVars

# if (Get-Module -ListAvailable -Name virtualenvwrapper) {
#     Import-Module virtualenvwrapper
# }

# If (Test-Path hklm:software\cygwin\setup)
# {

#     function Cygwin-Execute
#     {
#         If(!$Args)
#         {
#             Write-Host "Usage: $($MyInvocation.MyCommand) [command ...]"
#             Write-Host ""
#             Write-Host "Runs the command from a Cygwin shell."
#         }
#         else
#         {
#             $cygroot = (Get-ItemProperty hklm:software\cygwin\setup).rootdir

# 	    Try
# 	    {
# 	        $TEMP_HOME=$Env:HOME
# 	        $env:HOME="$cygroot\home\$([Environment]::UserName)"
#                 $env:CHERE_INVOKING=1
#             & "$cygroot\bin\sh.exe" --login -c "$Args"
# 	    }
# 	    Finally
# 	    {
#                 $Env:HOME=$TEMP_HOME
# 	    }
#         }
#     }

#     Set-Alias c Cygwin-Execute
# }

# function which ([string] $cmd) {
#     $path = (Get-Command $cmd).Path
# }
