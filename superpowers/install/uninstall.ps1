# superpowers skill set - standalone uninstaller (PowerShell, ASCII-only).
# Works without the original repo. Only removes what this kit installed
# (+ old "superpower" singular leftovers, after a fingerprint check).
#
# Usage:
#   .\uninstall.ps1                                  # uninstall global Claude Code (~\.claude)
#   .\uninstall.ps1 -WithQoder                      # also global Qoder (~\.qoder)
#   .\uninstall.ps1 -WithTrae                       # also global Trae  (~\.trae-cn / ~\.trae)
#   .\uninstall.ps1 -WithAll                        # Claude Code + Qoder + Trae
#   .\uninstall.ps1 -Project 'D:\code\myproj'       # uninstall a project (.claude\ + CLAUDE.md block)
#   .\uninstall.ps1 -Project 'D:\code\myproj' -WithAll
#   .\uninstall.ps1 -DryRun ...                     # print only, delete nothing
#
# Note: equivalent to install.ps1 -Uninstall but standalone (no repo needed).

[CmdletBinding()]
param(
  [string]$Project = "",
  [switch]$WithQoder,
  [switch]$WithTrae,
  [switch]$WithAll,
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

$Begin       = "<!-- superpowers-sinosafe:begin -->"
$End         = "<!-- superpowers-sinosafe:end -->"
$LegacyBegin = "<!-- superpower-sinosafe:begin -->"
$LegacyEnd   = "<!-- superpower-sinosafe:end -->"

if ($WithAll) { $WithQoder = $true; $WithTrae = $true }

function Step {
  param([scriptblock]$Action)
  Write-Host "+ $($Action.ToString().Trim())"
  if (-not $DryRun) { & $Action }
}
function Remove-BlockFromText {
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

# --- legacy "superpower" (singular) cleanup: fingerprint check before remove ---
function Test-OurLegacyDir {
  param([string]$Dir)
  $skill = Join-Path $Dir "SKILL.md"
  if (-not (Test-Path $skill)) { return $false }
  $c = Read-FileText $skill
  if ($c -match 'Superpowers Methodology') { return $true }
  if ($c -match 'brainstorming' -and $c -match 'writing-plans') { return $true }
  return $false
}
function Remove-LegacySkillDir {
  param([string]$SkillsDir)
  $ld = Join-Path $SkillsDir "superpower"
  if (-not (Test-Path $ld)) { return }
  if (Test-OurLegacyDir $ld) { Step { Remove-Item -Recurse -Force $ld -ErrorAction SilentlyContinue } }
  else { Write-Host "    [skip] $ld - fingerprint mismatch, left untouched." }
}
function Remove-LegacyFile {
  param([string]$Path, [string]$Needle = 'brainstorming')
  if (-not (Test-Path $Path)) { return }
  if ((Read-FileText $Path) -match $Needle) { Step { Remove-Item -Force $Path } }
  else { Write-Host "    [skip] $Path - not our legacy, left untouched." }
}

function Uninstall-Claude {
  param([string]$Root)
  Write-Host "===> Uninstall Claude Code: $Root"
  Remove-LegacySkillDir (Join-Path $Root "skills")
  Remove-LegacyFile (Join-Path $Root "commands\superpower.md")
  foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Root "skills\$s") -ErrorAction SilentlyContinue } }
  Step { Remove-Item -Force (Join-Path $Root "commands\superpowers.md") -ErrorAction SilentlyContinue }
}
function Uninstall-Qoder {
  param([string]$Root)
  Write-Host "===> Uninstall Qoder: $Root"
  Remove-LegacySkillDir (Join-Path $Root "skills")
  Remove-LegacyFile (Join-Path $Root "rules\superpower-sinosafe.md")
  foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $Root "skills\$s") -ErrorAction SilentlyContinue } }
  Step { Remove-Item -Force (Join-Path $Root "rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
}
function Resolve-TraeRoot {
  param([string]$Parent, [string]$Scope)
  if ($Scope -eq "global") {
    $cn = Join-Path $Parent ".trae-cn"
    if (Test-Path $cn) { return $cn }
    $intl = Join-Path $Parent ".trae"
    if (Test-Path $intl) { return $intl }
    return $cn
  }
  return Join-Path $Parent ".trae"
}
function Uninstall-Trae {
  param([string]$Parent, [string]$Scope)
  $root = Resolve-TraeRoot -Parent $Parent -Scope $Scope
  Write-Host "===> Uninstall Trae: $root"
  Remove-LegacySkillDir (Join-Path $root "skills")
  Remove-LegacyFile (Join-Path $root "rules\superpower-sinosafe.md")
  foreach ($s in $SkillNames) { Step { Remove-Item -Recurse -Force (Join-Path $root "skills\$s") -ErrorAction SilentlyContinue } }
  Step { Remove-Item -Force (Join-Path $root "rules\superpowers-sinosafe.md") -ErrorAction SilentlyContinue }
}

if ($Project -eq "") {
  Uninstall-Claude -Root (Join-Path $HOME ".claude")
  if ($WithQoder) { Uninstall-Qoder -Root (Join-Path $HOME ".qoder") }
  if ($WithTrae)  { Uninstall-Trae  -Parent $HOME -Scope "global" }
  Write-Host "    (global mode: CLAUDE.md not touched)"
} else {
  Uninstall-Claude -Root (Join-Path $Project ".claude")
  $cmd = Join-Path $Project "CLAUDE.md"
  if (Test-Path $cmd) {
    $rest = Read-FileText $cmd
    $rest = Remove-BlockFromText -Text $rest
    $rest = Remove-BlockFromText -Text $rest -B $LegacyBegin -E $LegacyEnd
    Step { Write-Utf8NoBom -Path $cmd -Text $rest }
  }
  if ($WithQoder) { Uninstall-Qoder -Root (Join-Path $Project ".qoder") }
  if ($WithTrae)  { Uninstall-Trae  -Parent $Project -Scope "project" }
}

Write-Host ""
$suffix = if ($DryRun) { "(dry-run, nothing deleted)" } else { "" }
Write-Host "Uninstall done. $suffix"
Write-Host "To reinstall: .\install\install.ps1  (or the remote one-liner, see the share guide)"
