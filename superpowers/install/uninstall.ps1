# superpowers skill set - standalone uninstaller (PowerShell, ASCII-only).
# Works without the original repo. Only removes what this kit installed.
#
# Usage:
#   .\uninstall.ps1                                  # uninstall global Claude Code (~\.claude)
#   .\uninstall.ps1 -Project 'D:\code\myproj'        # uninstall a project (.claude\ + CLAUDE.md block)
#   .\uninstall.ps1 -Project 'D:\code\myproj' -WithQoder   # also Qoder (.qoder\)
#   .\uninstall.ps1 -DryRun ...                      # print only, delete nothing
#
# Note: equivalent to install.ps1 -Uninstall but standalone (no repo needed).

[CmdletBinding()]
param(
  [string]$Project = "",
  [switch]$WithQoder,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$SkillNames = @(
  "superpowers",
  "brainstorming",
  "writing-plans",
  "test-driven-development",
  "systematic-debugging",
  "verification-before-completion"
)

$Begin = "<!-- superpowers-sinosafe:begin -->"
$End   = "<!-- superpowers-sinosafe:end -->"

function Step {
  param([scriptblock]$Action)
  Write-Host "+ $($Action.ToString().Trim())"
  if (-not $DryRun) { & $Action }
}
function Remove-BlockFromText {
  param([string]$Text)
  $pattern = [regex]::Escape($Begin) + '[\s\S]*?' + [regex]::Escape($End) + '\r?\n?'
  return [regex]::Replace($Text, $pattern, '')
}
function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

if ($Project -eq "") {
  Write-Host "===> Uninstall global Claude Code: $HOME\.claude"
  foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $HOME ".claude\skills\$s") -ErrorAction SilentlyContinue } }
  Step { Remove-Item -Force (Join-Path $HOME ".claude\commands\superpowers.md") -ErrorAction SilentlyContinue }
  Write-Host "    (global mode: CLAUDE.md not touched)"
} else {
  Write-Host "===> Uninstall project Claude Code: $Project\.claude"
  foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Project ".claude\skills\$s") -ErrorAction SilentlyContinue } }
  Step { Remove-Item -Force (Join-Path $Project ".claude\commands\superpowers.md") -ErrorAction SilentlyContinue }
  $cmd = Join-Path $Project "CLAUDE.md"
  if (Test-Path $cmd) {
    $rest = Remove-BlockFromText -Text (Get-Content -LiteralPath $cmd -Raw -Encoding UTF8)
    Step { Write-Utf8NoBom -Path $cmd -Text $rest }
  }
  if ($WithQoder) {
    Write-Host "===> Uninstall Qoder: $Project\.qoder"
    foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Project ".qoder\skills\$s") -ErrorAction SilentlyContinue } }
    Step { Remove-Item -Force (Join-Path $Project ".qoder\rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
  }
}

Write-Host ""
$suffix = if ($DryRun) { "(dry-run, nothing deleted)" } else { "" }
Write-Host "Uninstall done. $suffix"
Write-Host "To reinstall: .\install\install.ps1  (or the remote one-liner, see the share guide)"
