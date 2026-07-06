# superpowers skill set - one-click deploy to Claude Code / Qoder (PowerShell)
# NOTE: messages kept ASCII-only so PS 5.1 reads this file correctly on any locale.
#
# Usage:
#   .\install.ps1                                  # global Claude Code: ~\.claude\skills\
#   .\install.ps1 -Project 'D:\code\myproj'        # project: \.claude\skills\ + CLAUDE.md bootstrap
#   .\install.ps1 -Project 'D:\code\myproj' -WithQoder   # also Qoder: \.qoder\skills\ + \.qoder\rules\
#   .\install.ps1 -DryRun ...                      # print only, no writes
#   .\install.ps1 -Uninstall ...                   # remove by sentinel (never touches user content)
#
# Review the staging repo first, then run. --DryRun to preview.

[CmdletBinding()]
param(
  [string]$Project = "",
  [switch]$WithQoder,
  [switch]$DryRun,
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$SrcSkills   = Join-Path $RepoRoot "skills"
$SrcCommands = Join-Path $RepoRoot "commands"
$Snippet     = Join-Path $RepoRoot "bootstrap\CLAUDE.md.snippet"
$QoderRule   = Join-Path $RepoRoot "bootstrap\qoder-rule.md"

$Begin = "<!-- superpower-sinosafe:begin -->"
$End   = "<!-- superpower-sinosafe:end -->"

$SkillNames = @(
  "superpower",
  "brainstorming",
  "writing-plans",
  "test-driven-development",
  "systematic-debugging",
  "verification-before-completion"
)

function Step {
  # print and (unless DryRun) execute
  param([scriptblock]$Action)
  Write-Host "+ $($Action.ToString().Trim())"
  if (-not $DryRun) { & $Action }
}

function Remove-BlockFromText {
  # raw text in -> sentinel block removed -> text out (preserves everything else)
  param([string]$Text)
  $pattern = [regex]::Escape($Begin) + '[\s\S]*?' + [regex]::Escape($End) + '\r?\n?'
  return [regex]::Replace($Text, $pattern, '')
}

function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function Inject-Block {
  param([string]$File)
  $raw = if (Test-Path $File) { Get-Content -LiteralPath $File -Raw -Encoding UTF8 } else { "" }
  $raw = Remove-BlockFromText -Text $raw
  $snippet = Get-Content -LiteralPath $Snippet -Raw -Encoding UTF8
  if ($raw -and -not $raw.EndsWith("`n")) { $raw += "`r`n" }
  $raw += "`r`n" + $snippet
  Step { Write-Utf8NoBom -Path $File -Text $raw }
}

function Install-Claude {
  param([string]$DestRoot)
  Write-Host "===> Claude Code: $DestRoot"
  $skillsDir = Join-Path $DestRoot "skills"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null }
  foreach ($s in $SkillNames) {
    $target = Join-Path $skillsDir $s
    Step { Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue }
    Step { Copy-Item -Recurse -Force (Join-Path $SrcSkills $s) $target }
  }
  # /superpower slash command (Claude Code only; Qoder uses the superpower skill)
  $cmdsDir = Join-Path $DestRoot "commands"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $cmdsDir | Out-Null }
  Step { Copy-Item -Force (Join-Path $SrcCommands "superpower.md") (Join-Path $cmdsDir "superpower.md") }
  if ($Project -ne "") {
    Inject-Block -File (Join-Path $Project "CLAUDE.md")
  } else {
    Write-Host "    (global mode: CLAUDE.md not touched. To enable bootstrap, append bootstrap\CLAUDE.md.snippet to a project CLAUDE.md)"
  }
}

function Install-Qoder {
  param([string]$Proj)
  Write-Host "===> Qoder: $Proj\.qoder"
  $skillsDir = Join-Path $Proj ".qoder\skills"
  $rulesDir  = Join-Path $Proj ".qoder\rules"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $skillsDir, $rulesDir | Out-Null }
  foreach ($s in $SkillNames) {
    $target = Join-Path $skillsDir $s
    Step { Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue }
    Step { Copy-Item -Recurse -Force (Join-Path $SrcSkills $s) $target }
  }
  Step { Copy-Item -Force $QoderRule (Join-Path $rulesDir "superpower-sinosafe.md") }
}

function Do-Uninstall {
  if ($Project -ne "") {
    $cs = Join-Path $Project ".claude\skills"
    Write-Host "===> Uninstall Claude Code (project): $cs"
    foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $cs $s) -ErrorAction SilentlyContinue } }
    Step { Remove-Item -Force (Join-Path $Project ".claude\commands\superpower.md") -ErrorAction SilentlyContinue }
    $cmd = Join-Path $Project "CLAUDE.md"
    if (Test-Path $cmd) {
      $rest = Remove-BlockFromText -Text (Get-Content -LiteralPath $cmd -Raw -Encoding UTF8)
      Step { Write-Utf8NoBom -Path $cmd -Text $rest }
    }
    if ($WithQoder) {
      Write-Host "===> Uninstall Qoder (project): $Project\.qoder"
      foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Project ".qoder\skills\$s") -ErrorAction SilentlyContinue } }
      Step { Remove-Item -Force (Join-Path $Project ".qoder\rules\superpower-sinosafe.md") -ErrorAction SilentlyContinue }
    }
  } else {
    $cs = Join-Path $HOME ".claude\skills"
    Write-Host "===> Uninstall Claude Code (global): $cs"
    foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $cs $s) -ErrorAction SilentlyContinue } }
    Step { Remove-Item -Force (Join-Path $HOME ".claude\commands\superpower.md") -ErrorAction SilentlyContinue }
    Write-Host "    (global mode: CLAUDE.md not touched)"
  }
  Write-Host "Uninstall done."
  exit 0
}

if ($Uninstall) { Do-Uninstall }

if ($Project -eq "") {
  Install-Claude -DestRoot (Join-Path $HOME ".claude")
  if ($WithQoder) { Write-Error "-WithQoder requires -Project (Qoder is project-scoped)"; exit 2 }
} else {
  Install-Claude -DestRoot (Join-Path $Project ".claude")
  if ($WithQoder) { Install-Qoder -Proj $Project }
}

Write-Host ""
$suffix = if ($DryRun) { "(dry-run, nothing written)" } else { "" }
Write-Host "Done. $suffix"
Write-Host "Next: in Claude Code type /superpower (or in Qoder say 'enable superpowers'); all following tasks then follow the methodology."
