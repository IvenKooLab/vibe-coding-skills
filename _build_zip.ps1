$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$out = Join-Path (Split-Path $src -Parent) "superpowers-skills.zip"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Clean previous package
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }

# Files to exclude from the distributable (local dev helpers)
$exclude = @("_validate.ps1", "_build_zip.ps1")

$zip = [System.IO.Compression.ZipFile]::Open($out, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  $files = Get-ChildItem -LiteralPath $src -Recurse -File |
           Where-Object { $exclude -notcontains $_.Name }
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($src.Length).TrimStart('\','/') -replace '\\','/'
    $entryName = "superpowers/" + $rel
    $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
    $entry.LastWriteTime = $f.LastWriteTime
    $fs = [System.IO.File]::OpenRead($f.FullName)
    $es = $entry.Open()
    try { $fs.CopyTo($es) } finally { $es.Dispose(); $fs.Dispose() }
  }
} finally { $zip.Dispose() }

# .NET Framework stores entry names as correct UTF-8 bytes but does NOT set
# the language-encoding flag (general-purpose bit 11). Without it, unzip treats
# the bytes as CP437 and re-encodes -> mojibake on Mac/Linux. Patch both the
# central-directory and local headers to set bit 11, parsed properly (no scan).
$bytes = [System.IO.File]::ReadAllBytes($out)
$len = $bytes.Length
$eocd = -1
for ($i = $len - 22; $i -ge 0; $i--) {
  if ($bytes[$i] -eq 0x50 -and $bytes[$i+1] -eq 0x4B -and $bytes[$i+2] -eq 0x05 -and $bytes[$i+3] -eq 0x06) { $eocd = $i; break }
}
if ($eocd -lt 0) { throw "EOCD record not found" }
$cdOffset = [BitConverter]::ToInt32($bytes, $eocd + 16)
$pos = $cdOffset; $count = 0
while ($pos + 46 -le $len) {
  if (-not ($bytes[$pos] -eq 0x50 -and $bytes[$pos+1] -eq 0x4B -and $bytes[$pos+2] -eq 0x01 -and $bytes[$pos+3] -eq 0x02)) { break }
  $bytes[$pos + 9] = $bytes[$pos + 9] -bor 0x08            # central-dir flag high byte = bit 11
  $lh = [BitConverter]::ToInt32($bytes, $pos + 42)         # local header offset
  if ($lh -ge 0 -and $lh + 30 -le $len) { $bytes[$lh + 7] = $bytes[$lh + 7] -bor 0x08 }
  $nameLen    = [BitConverter]::ToInt16($bytes, $pos + 28)
  $extraLen   = [BitConverter]::ToInt16($bytes, $pos + 30)
  $commentLen = [BitConverter]::ToInt16($bytes, $pos + 32)
  $pos = $pos + 46 + $nameLen + $extraLen + $commentLen
  $count++
}
[System.IO.File]::WriteAllBytes($out, $bytes)
Write-Host ("OK -> " + $out + "  (UTF-8 flag set on " + $count + " entries)")
