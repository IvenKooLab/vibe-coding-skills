# Embed the 5 SKILL.md files into the guide .docx as Word OLE package attachments
# (double-click the icon to open the file). ASCII-only source. Self-contained:
# finds the .docx next to itself, skills/ in the parent directory.

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$docxFile = Get-ChildItem -LiteralPath $here -Filter *.docx | Select-Object -First 1
if ($null -eq $docxFile) { throw "No .docx found next to script." }
$docx = $docxFile.FullName
$skillsDir = Join-Path (Split-Path -Parent $here) "skills"
if (-not (Test-Path $skillsDir)) { throw "skills dir not found: " + $skillsDir }

$skillFiles = Get-ChildItem -LiteralPath $skillsDir -Recurse -Filter "SKILL.md" | Where-Object { $_.Directory.Name -ne "superpower" } | Sort-Object DirectoryName
Write-Output ("Found " + $skillFiles.Count + " SKILL.md files; embedding into " + $docxFile.Name)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$missing = [System.Reflection.Missing]::Value
$embedded = 0
try {
  $doc = $word.Documents.Open($docx)
  $sel = $word.Selection
  $sel.EndKey(6) | Out-Null   # wdStory -> end of document
  $sel.TypeParagraph()
  $sel.Font.Bold = 1
  $sel.TypeText("Appendix - 5 skill files (double-click any icon to open)")
  $sel.Font.Bold = 0
  $sel.TypeParagraph()

  foreach ($f in $skillFiles) {
    $sel.EndKey(6) | Out-Null
    $sel.TypeParagraph()
    $sel.Font.Bold = 1
    $sel.TypeText("Attachment: " + $f.Directory.Name + " / SKILL.md")
    $sel.Font.Bold = 0
    $sel.TypeParagraph()
    try {
      $label = $f.Directory.Name + "-SKILL.md"
      $sel.InlineShapes.AddOLEObject($missing, $f.FullName, $false, $true, $missing, $missing, $label, $missing) | Out-Null
      $embedded++
    } catch {
      Write-Output ("  WARN embed failed for " + $f.Name + ": " + $_.Exception.Message)
    }
    $sel.TypeParagraph()
  }
  $total = $doc.InlineShapes.Count
  $doc.Save()
  $doc.Close()
  Write-Output ("Embedded " + $embedded + "/" + $skillFiles.Count + " files; InlineShapes in doc = " + $total)
} finally {
  $word.Quit()
  [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
  [GC]::Collect()
}
