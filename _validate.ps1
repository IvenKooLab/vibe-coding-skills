$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$skillsDir = Join-Path $root "skills"
$pass = 0; $fail = 0; $totalChars = 0
function Check($cond, $msg) {
  if ($cond) { Write-Host "  PASS  $msg" -ForegroundColor Green; $script:pass++ }
  else       { Write-Host "  FAIL  $msg" -ForegroundColor Red;   $script:fail++ }
}
Get-ChildItem $skillsDir -Directory | Sort-Object Name | ForEach-Object {
  $dir = $_.Name
  $f = Join-Path $_.FullName "SKILL.md"
  Write-Host ""
  Write-Host "=== $dir ==="
  $raw = Get-Content -LiteralPath $f -Raw -Encoding UTF8
  $lines = Get-Content -LiteralPath $f -Encoding UTF8
  $script:totalChars += $raw.Length
  Check ($lines.Count -lt 500) ("body lines $($lines.Count) < 500")
  $fm = @{}; $inFm = $false
  foreach ($l in $lines) {
    if ($l -eq "---") { if ($inFm) { break } else { $inFm = $true; continue } }
    if ($inFm -and $l -match '^\s*([A-Za-z][\w-]*)\s*:\s*(.*)$') { $fm[$matches[1]] = $matches[2].Trim() }
  }
  $name = $fm['name']
  Check ($name -eq $dir) ("name='$name' == dir '$dir'")
  Check ($name -match '^[a-z0-9]+(-[a-z0-9]+)*$') "name kebab-case"
  $desc = $fm['description']
  if ($null -ne $desc) {
    Check ($desc.Length -le 1024) ("desc length $($desc.Length) <= 1024")
    Check ($desc.StartsWith("Use ")) "desc starts with 'Use' (trigger wording)"
  } else { Check $false "description exists" }
}
Write-Host ""
$color = if ($fail -eq 0) { 'Green' } else { 'Yellow' }
Write-Host ("TOTAL: PASS=$pass  FAIL=$fail") -ForegroundColor $color
Write-Host ("Skill files total chars: $totalChars  (~tokens est: " + [math]::Round($totalChars/4) + " for English; Chinese equivalent ~" + [math]::Round($totalChars*1.5) + " chars ~ " + [math]::Round($totalChars*1.5/1.4) + " tokens)") -ForegroundColor Cyan
if ($fail -gt 0) { exit 1 }
