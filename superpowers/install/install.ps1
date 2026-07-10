# superpowers skill set - one-click deploy to Claude Code / Qoder / Trae (PowerShell)
# NOTE: messages kept ASCII-only so PS 5.1 reads this file correctly on any locale.
#
# Usage:
#   .\install.ps1                                  # global: adapt every IDE already installed
#   .\install.ps1 -WithClaude                      # force Claude Code (global ~/.claude | project .claude)
#   .\install.ps1 -WithQoder                       # also Qoder (global ~/.qoder | project .qoder)
#   .\install.ps1 -WithTrae                        # also Trae  (global ~/.trae-cn / ~/.trae | project .trae)
#   .\install.ps1 -WithAll                         # Claude Code + Qoder + Trae together
#   .\install.ps1 -Project 'D:\code\myproj'        # project: \.claude\skills\ + CLAUDE.md bootstrap
#   .\install.ps1 -DryRun ...                      # print only, no writes
#   .\install.ps1 -Uninstall ...                   # remove by sentinel (never touches user content)
#
# No -Project, global: auto-adapts every IDE config dir that already exists (~/.claude,
# ~/.qoder, ~/.trae-cn, ~/.trae). Dirs for IDEs you do NOT have are never created. If
# none exist, the run aborts with a hint (run an IDE once, or pass -With* / -WithAll).
# Re-running is always safe.
#
# Legacy cleanup: this project used to be named "superpower" (singular). Before each
# install the dest is scanned for leftovers (skills\superpower\, commands\superpower.md,
# qoder rule superpower-sinosafe.md). A folder/file is removed ONLY after a content
# fingerprint check confirms it is ours - a third-party item named "superpower" is left
# untouched. The OLD CLAUDE.md sentinel block (superpower-sinosafe:begin..end) IS safely
# stripped here (PS has regex; the .bat cannot).

[CmdletBinding()]
param(
  [string]$Project = "",
  [switch]$WithClaude,
  [switch]$WithQoder,
  [switch]$WithTrae,
  [switch]$WithAll,
  [switch]$DryRun,
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$RepoRoot    = $PSScriptRoot | Split-Path -Parent
$SrcSkills   = Join-Path $RepoRoot "skills"
$SrcCommands = Join-Path $RepoRoot "commands"
$Snippet     = Join-Path $RepoRoot "bootstrap\CLAUDE.md.snippet"
$QoderRule   = Join-Path $RepoRoot "bootstrap\qoder-rule.md"

$Begin       = "<!-- superpowers-sinosafe:begin -->"
$End         = "<!-- superpowers-sinosafe:end -->"
$LegacyBegin = "<!-- superpower-sinosafe:begin -->"
$LegacyEnd   = "<!-- superpower-sinosafe:end -->"

# brainstorming / writing-plans / test-driven-development / systematic-debugging /
# verification-before-completion were merged into the single `superpowers` skill.
$SkillNames = @("superpowers")
# pre-merge per-discipline dirs cleaned up by Remove-LegacySkillDir (fingerprinted).
$MergedLegacyDirs = @(
  "brainstorming", "writing-plans", "test-driven-development",
  "systematic-debugging", "verification-before-completion"
)

if ($WithAll) { $WithClaude = $true; $WithQoder = $true; $WithTrae = $true }

function Step {
  # print and (unless DryRun) execute
  param([scriptblock]$Action)
  Write-Host "+ $($Action.ToString().Trim())"
  if (-not $DryRun) { & $Action }
}

function Remove-BlockFromText {
  # raw text in -> one sentinel block removed -> text out (preserves everything else)
  param([string]$Text, [string]$B = $Begin, [string]$E = $End)
  $pattern = [regex]::Escape($B) + '[\s\S]*?' + [regex]::Escape($E) + '\r?\n?'
  return [regex]::Replace($Text, $pattern, '')
}

function Write-Utf8NoBom {
  param([string]$Path, [string]$Text)
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function Read-FileText {
  param([string]$Path)
  if (Test-Path $Path) { return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 } else { return "" }
}

function Inject-Block {
  param([string]$File)
  $raw = Read-FileText $File
  # strip BOTH old singular and new plural sentinel blocks, then append fresh
  $raw = Remove-BlockFromText -Text $raw
  $raw = Remove-BlockFromText -Text $raw -B $LegacyBegin -E $LegacyEnd
  $snippet = Get-Content -LiteralPath $Snippet -Raw -Encoding UTF8
  if ($raw -and -not $raw.EndsWith("`n")) { $raw += "`r`n" }
  $raw += "`r`n" + $snippet
  Step { Write-Utf8NoBom -Path $File -Text $raw }
}

# --- legacy fingerprint check: is this dir our old "superpower" build? ---
function Test-OurLegacyDir {
  param([string]$Dir)
  $skill = Join-Path $Dir "SKILL.md"
  if (-not (Test-Path $skill)) { return $false }
  $c = Read-FileText $skill
  if ($c -match 'Superpowers Methodology') { return $true }
  if ($c -match 'brainstorming' -and $c -match 'writing-plans') { return $true }
  return $false
}

function Test-OurLegacyFile {
  param([string]$Path, [string]$Needle = 'brainstorming')
  if (-not (Test-Path $Path)) { return $false }
  return (Read-FileText $Path) -match $Needle
}

function Remove-LegacySkillDir {
  param([string]$SkillsDir)
  # 1) clean the oldest single-name "superpower" (pre-rename) dir
  $ld = Join-Path $SkillsDir "superpower"
  if (Test-Path $ld) {
    if (Test-OurLegacyDir $ld) {
      Step { Remove-Item -Recurse -Force $ld -ErrorAction SilentlyContinue }
    } else {
      Write-Host "    [skip] $ld - fingerprint mismatch, not our legacy, left untouched."
    }
  }
  # 2) clean the 5 pre-merge per-discipline dirs (merged into superpowers)
  foreach ($d in $MergedLegacyDirs) {
    $ld = Join-Path $SkillsDir $d
    if (-not (Test-Path $ld)) { continue }
    if (Test-OurLegacyDir $ld) {
      Step { Remove-Item -Recurse -Force $ld -ErrorAction SilentlyContinue }
    } else {
      Write-Host "    [skip] $ld - fingerprint mismatch, not our legacy, left untouched."
    }
  }
}

function Copy-Skills {
  param([string]$DestSkillsDir)
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $DestSkillsDir | Out-Null }
  foreach ($s in $SkillNames) {
    $target = Join-Path $DestSkillsDir $s
    Step { Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue }
    Step { Copy-Item -Recurse -Force (Join-Path $SrcSkills $s) $target }
  }
}

function Install-Claude {
  param([string]$DestRoot)
  Write-Host "===> Claude Code: $DestRoot"
  Remove-LegacySkillDir (Join-Path $DestRoot "skills")
  $lc = Join-Path $DestRoot "commands\superpower.md"
  if (Test-Path $lc) {
    if (Test-OurLegacyFile $lc) { Step { Remove-Item -Force $lc } }
    else { Write-Host "    [skip] $lc - not our legacy command, left untouched." }
  }
  Copy-Skills (Join-Path $DestRoot "skills")
  # /superpowers slash command (Claude Code only; Qoder/Trae use the superpowers skill)
  $cmdsDir = Join-Path $DestRoot "commands"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $cmdsDir | Out-Null }
  Step { Copy-Item -Force (Join-Path $SrcCommands "superpowers.md") (Join-Path $cmdsDir "superpowers.md") }
  if ($Project -ne "") {
    Inject-Block -File (Join-Path $Project "CLAUDE.md")
  } else {
    Write-Host "    (global mode: CLAUDE.md not touched. To enable bootstrap, append bootstrap\CLAUDE.md.snippet to a project CLAUDE.md)"
  }
}

function Install-Qoder {
  param([string]$Parent, [string]$Scope)
  $root = Join-Path $Parent ".qoder"
  Write-Host "===> Qoder [$Scope]: $root"
  Remove-LegacySkillDir (Join-Path $root "skills")
  $lr = Join-Path $root "rules\superpower-sinosafe.md"
  if (Test-Path $lr) {
    if (Test-OurLegacyFile $lr) { Step { Remove-Item -Force $lr } }
    else { Write-Host "    [skip] $lr - not our legacy rule, left untouched." }
  }
  $skillsDir = Join-Path $root "skills"
  $rulesDir  = Join-Path $root "rules"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $skillsDir, $rulesDir | Out-Null }
  Copy-Skills $skillsDir
  Step { Copy-Item -Force $QoderRule (Join-Path $rulesDir "superpowers-sinosafe.md") }
}

function Resolve-TraeRoot {
  # global: ~/.trae-cn, fallback ~/.trae if only that exists. project: <proj>\.trae
  param([string]$Parent, [string]$Scope)
  if ($Scope -eq "global") {
    $cn = Join-Path $Parent ".trae-cn"
    if (Test-Path $cn) { return $cn }
    $intl = Join-Path $Parent ".trae"
    if (Test-Path $intl) { return $intl }
    return $cn   # neither exists (forced install): create the CN-build default
  }
  return Join-Path $Parent ".trae"
}

function Install-Trae {
  param([string]$Parent, [string]$Scope)
  $root = Resolve-TraeRoot -Parent $Parent -Scope $Scope
  Write-Host "===> Trae [$Scope]: $root"
  Remove-LegacySkillDir (Join-Path $root "skills")
  $lr = Join-Path $root "rules\superpower-sinosafe.md"
  if (Test-Path $lr) {
    if (Test-OurLegacyFile $lr) { Step { Remove-Item -Force $lr } }
    else { Write-Host "    [skip] $lr - not our legacy rule, left untouched." }
  }
  $skillsDir = Join-Path $root "skills"
  $rulesDir  = Join-Path $root "rules"
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $skillsDir, $rulesDir | Out-Null }
  Copy-Skills $skillsDir
  Step { Copy-Item -Force $QoderRule (Join-Path $rulesDir "superpowers-sinosafe.md") }
}

function Do-Uninstall {
  if ($Project -ne "") {
    $cs = Join-Path $Project ".claude\skills"
    Write-Host "===> Uninstall Claude Code (project): $cs"
    foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $cs $s) -ErrorAction SilentlyContinue } }
    Step { Remove-Item -Force (Join-Path $Project ".claude\commands\superpowers.md") -ErrorAction SilentlyContinue }
    $cmd = Join-Path $Project "CLAUDE.md"
    if (Test-Path $cmd) {
      $rest = Read-FileText $cmd
      $rest = Remove-BlockFromText -Text $rest
      $rest = Remove-BlockFromText -Text $rest -B $LegacyBegin -E $LegacyEnd
      Step { Write-Utf8NoBom -Path $cmd -Text $rest }
    }
    if ($WithQoder) {
      Write-Host "===> Uninstall Qoder (project): $Project\.qoder"
      foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Project ".qoder\skills\$s") -ErrorAction SilentlyContinue } }
      Step { Remove-Item -Force (Join-Path $Project ".qoder\rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
    }
    if ($WithTrae) {
      Write-Host "===> Uninstall Trae (project): $Project\.trae"
      foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Project ".trae\skills\$s") -ErrorAction SilentlyContinue } }
      Step { Remove-Item -Force (Join-Path $Project ".trae\rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
    }
  } else {
    $cs = Join-Path $HOME ".claude\skills"
    Write-Host "===> Uninstall Claude Code (global): $cs"
    foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $cs $s) -ErrorAction SilentlyContinue } }
    Step { Remove-Item -Force (Join-Path $HOME ".claude\commands\superpowers.md") -ErrorAction SilentlyContinue }
    if ($WithQoder) {
      Write-Host "===> Uninstall Qoder (global): $HOME\.qoder"
      foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $HOME ".qoder\skills\$s") -ErrorAction SilentlyContinue } }
      Step { Remove-Item -Force (Join-Path $HOME ".qoder\rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
    }
    if ($WithTrae) {
      $troot = Resolve-TraeRoot -Parent $HOME -Scope "global"
      Write-Host "===> Uninstall Trae (global): $troot"
      foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $troot "skills\$s") -ErrorAction SilentlyContinue } }
      Step { Remove-Item -Force (Join-Path $troot "rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
    }
    Write-Host "    (global mode: CLAUDE.md not touched)"
  }
  Write-Host "Uninstall done."
  exit 0
}

if ($Uninstall) { Do-Uninstall }

if ($Project -eq "") {
  # auto-adapt: only IDEs whose config dir already exists (or were forced on)
  if (-not $WithClaude -and (Test-Path (Join-Path $HOME ".claude"))) {
    Write-Host "--- auto-detected Claude Code config: $HOME\.claude"
    $WithClaude = $true
  }
  if (-not $WithQoder -and (Test-Path (Join-Path $HOME ".qoder"))) {
    Write-Host "--- auto-detected Qoder config: $HOME\.qoder"
    $WithQoder = $true
  }
  if (-not $WithTrae -and ((Test-Path (Join-Path $HOME ".trae-cn")) -or (Test-Path (Join-Path $HOME ".trae")))) {
    Write-Host "--- auto-detected Trae config: $HOME\.trae-cn / .trae"
    $WithTrae = $true
  }
  if (-not ($WithClaude -or $WithQoder -or $WithTrae)) {
    Write-Host ""
    Write-Host "No IDE config dir found under your home (.claude / .qoder / .trae-cn / .trae)."
    Write-Host "Run Claude Code / Qoder / Trae once to create its config dir, then re-run;"
    Write-Host "or force an install with: -WithClaude  -WithQoder  -WithTrae  -WithAll"
    Write-Host ""
    exit 1
  }
  if ($WithClaude) { Install-Claude -DestRoot (Join-Path $HOME ".claude") }
  if ($WithQoder)  { Install-Qoder -Parent $HOME -Scope "global" }
  if ($WithTrae)   { Install-Trae  -Parent $HOME -Scope "global" }
} else {
  Install-Claude -DestRoot (Join-Path $Project ".claude")
  if ($WithQoder) { Install-Qoder -Parent $Project -Scope "project" }
  if ($WithTrae)  { Install-Trae  -Parent $Project -Scope "project" }
}

Write-Host ""
$suffix = if ($DryRun) { "(dry-run, nothing written)" } else { "" }
Write-Host "Done. $suffix"
Write-Host "Next: in Claude Code type /superpowers (or in Qoder / Trae say 'enable superpowers'); all following tasks then follow the methodology."
