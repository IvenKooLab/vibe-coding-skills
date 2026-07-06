# Markdown -> .docx generator (ASCII-only source; all CJK comes from the .md file
# read as UTF-8, so PS 5.1 ANSI read is never an issue). Function names are EmitX
# to avoid clashing with built-in aliases (e.g. h = Get-History).
#
# Self-contained: finds the .md next to this script, writes a same-name .docx,
# derives the doc title from the first "# " heading. Just run with no args.
#   powershell -NoProfile -ExecutionPolicy Bypass -File _gen_docx.ps1
#
# Supported MD subset: #/##/### headings, paragraphs, "- " bullets, "1. " numbered,
# "> " callouts, ``` code fences, "| a | b |" tables (with | --- | sep), "---" hr,
# inline **bold** and `code`.

param(
  [string]$InputMd = "",
  [string]$OutputDocx = "",
  [string]$Title = ""
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

if ($InputMd -eq "") {
  $md = Get-ChildItem -LiteralPath $PSScriptRoot -Filter *.md | Select-Object -First 1
  if ($null -eq $md) { throw "No .md found next to script; pass -InputMd." }
  $InputMd = $md.FullName
}
if ($OutputDocx -eq "") {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($InputMd)
  $OutputDocx = Join-Path ([System.IO.Path]::GetDirectoryName($InputMd)) ($base + '.docx')
}

# ---------- XML helpers ----------
function EscText($s) { return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;') }
function PlainRun($t) { return '<w:r><w:t xml:space="preserve">' + $t + '</w:t></w:r>' }
function Inline($text) {
  $sb = New-Object System.Text.StringBuilder
  $pat = '\*\*(.+?)\*\*|`([^`]+)`'
  $last = 0
  foreach ($m in [regex]::Matches($text, $pat)) {
    if ($m.Index -gt $last) { [void]$sb.Append((PlainRun (EscText $text.Substring($last, $m.Index - $last)))) }
    if ($m.Groups[1].Success) {
      [void]$sb.Append('<w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">' + (EscText $m.Groups[1].Value) + '</w:t></w:r>')
    } elseif ($m.Groups[2].Success) {
      [void]$sb.Append('<w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">' + (EscText $m.Groups[2].Value) + '</w:t></w:r>')
    }
    $last = $m.Index + $m.Length
  }
  if ($last -lt $text.Length) { [void]$sb.Append((PlainRun (EscText $text.Substring($last)))) }
  return $sb.ToString()
}

# ---------- block emitters ----------
function EmitH($level, $text) { '<w:p><w:pPr><w:pStyle w:val="Heading' + $level + '"/></w:pPr>' + (Inline $text) + '</w:p>' }
function EmitP($text) { '<w:p><w:pPr><w:spacing w:after="120"/></w:pPr>' + (Inline $text) + '</w:p>' }
function EmitBul($items) {
  $out = ''
  foreach ($it in $items) { $out += '<w:p><w:pPr><w:spacing w:after="60"/><w:ind w:left="420" w:hanging="280"/></w:pPr><w:r><w:t xml:space="preserve">' + ([char]0x2022) + '  </w:t></w:r>' + (Inline $it) + '</w:p>' }
  return $out
}
function EmitNum($items) {
  $out = ''; $i = 1
  foreach ($it in $items) { $out += '<w:p><w:pPr><w:spacing w:after="60"/><w:ind w:left="480" w:hanging="360"/></w:pPr><w:r><w:t xml:space="preserve">' + $i + '. </w:t></w:r>' + (Inline $it) + '</w:p>'; $i++ }
  return $out
}
function EmitNote($text) {
  '<w:p><w:pPr><w:spacing w:after="120"/><w:ind w:left="120" w:right="120"/><w:pBdr><w:left w:val="single" w:sz="24" w:space="8" w:color="F2C811"/></w:pBdr><w:shd w:val="clear" w:color="auto" w:fill="FFF4CE"/></w:pPr>' + (Inline $text) + '</w:p>'
}
function EmitHr() { '<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="BFBFBF"/></w:pBdr><w:spacing w:after="120"/></w:pPr></w:p>' }
function EmitCode($lines) {
  $runs = ''; $first = $true
  foreach ($ln in $lines) {
    if ($first) { $runs += '<w:t xml:space="preserve">' + (EscText $ln) + '</w:t>'; $first = $false }
    else { $runs += '<w:br/><w:t xml:space="preserve">' + (EscText $ln) + '</w:t>' }
  }
  '<w:p><w:pPr><w:spacing w:after="120"/><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/><w:ind w:left="120"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="20"/></w:rPr>' + $runs + '</w:r></w:p>'
}
function EmitTbl($headers, $rows) {
  $ncol = $headers.Count
  $colw = [math]::Floor(9000 / $ncol)
  $grid = ''; for ($c=0; $c -lt $ncol; $c++) { $grid += '<w:gridCol w:w="' + $colw + '"/>' }
  $borders = '<w:tblBorders><w:top w:val="single" w:sz="4" w:color="BFBFBF"/><w:left w:val="single" w:sz="4" w:color="BFBFBF"/><w:bottom w:val="single" w:sz="4" w:color="BFBFBF"/><w:right w:val="single" w:sz="4" w:color="BFBFBF"/><w:insideH w:val="single" w:sz="4" w:color="BFBFBF"/><w:insideV w:val="single" w:sz="4" w:color="BFBFBF"/></w:tblBorders>'
  $out = '<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/>' + $borders + '<w:tblLook w:val="04A0"/></w:tblPr><w:tblGrid>' + $grid + '</w:tblGrid>'
  $out += '<w:tr><w:trPr><w:tblHeader/></w:trPr>'
  foreach ($hh in $headers) { $out += '<w:tc><w:tcPr><w:tcW w:w="' + $colw + '" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="D9D9D9"/></w:tcPr><w:p><w:r><w:rPr><w:b/></w:rPr>' + (Inline $hh) + '</w:r></w:p></w:tc>' }
  $out += '</w:tr>'
  foreach ($row in $rows) {
    $out += '<w:tr>'
    for ($c=0; $c -lt $ncol; $c++) { $cell = if ($c -lt $row.Count) { $row[$c] } else { '' }; $out += '<w:tc><w:tcPr><w:tcW w:w="' + $colw + '" w:type="dxa"/></w:tcPr><w:p>' + (Inline $cell) + '</w:p></w:tc>' }
    $out += '</w:tr>'
  }
  $out + '</w:tbl><w:p/>'
}

# ---------- MD parser ----------
function Split-Row($line) {
  $s = $line.Trim()
  if ($s.StartsWith('|')) { $s = $s.Substring(1) }
  if ($s.EndsWith('|')) { $s = $s.Substring(0, $s.Length - 1) }
  return ($s -split '\|')
}

$lines = Get-Content -LiteralPath $InputMd -Encoding UTF8
if ($Title -eq "") {
  foreach ($ln in $lines) { if ("$ln".Trim() -match '^#\s+(.*)$') { $Title = $matches[1]; break } }
  if ($Title -eq "") { $Title = [System.IO.Path]::GetFileNameWithoutExtension($InputMd) }
}

$body = New-Object System.Text.StringBuilder
$i = 0
while ($i -lt $lines.Count) {
  $line = $lines[$i]
  $trim = "$line".Trim()
  if ($trim -eq '```') { $i++; $code = @(); while ($i -lt $lines.Count -and $lines[$i].Trim() -ne '```') { $code += $lines[$i]; $i++ }; [void]$body.Append((EmitCode $code)); $i++; continue }
  if ($trim -eq '---') { [void]$body.Append((EmitHr)); $i++; continue }
  if ($trim -eq '') { $i++; continue }
  if ($trim -match '^(#{1,3})\s+(.*)$') { [void]$body.Append((EmitH $matches[1].Length $matches[2])); $i++; continue }
  if ($trim -match '^>\s?(.*)$') { [void]$body.Append((EmitNote $matches[1])); $i++; continue }
  if ($trim -match '^-\s+(.*)$') { $items = @(); while ($i -lt $lines.Count -and $lines[$i].Trim() -match '^-\s+(.*)$') { $items += $matches[1]; $i++ }; [void]$body.Append((EmitBul $items)); continue }
  if ($trim -match '^\d+\.\s+(.*)$') { $items = @(); while ($i -lt $lines.Count -and $lines[$i].Trim() -match '^\d+\.\s+(.*)$') { $items += $matches[1]; $i++ }; [void]$body.Append((EmitNum $items)); continue }
  if ($trim.StartsWith('|')) {
    $next = if ($i + 1 -lt $lines.Count) { $lines[$i+1].Trim() } else { '' }
    if ($next -match '^\|[\s\-:|]+\|$') {
      $headers = Split-Row $line | ForEach-Object { $_.Trim() }
      $i += 2; $rows = @()
      while ($i -lt $lines.Count -and $lines[$i].Trim().StartsWith('|')) { $rows += , (Split-Row $lines[$i] | ForEach-Object { $_.Trim() }); $i++ }
      [void]$body.Append((EmitTbl $headers $rows)); continue
    }
  }
  $para = @()
  $started = $i
  while ($i -lt $lines.Count) {
    $t = $lines[$i].Trim()
    if ($t -eq '' -or $t.StartsWith('#') -or $t.StartsWith('- ') -or $t.StartsWith('> ') -or $t -eq '```' -or $t -eq '---' -or ($t -match '^\d+\.\s+') -or $t.StartsWith('|')) { break }
    $para += $lines[$i]; $i++
  }
  if ($i -eq $started) { $para = @($lines[$i]); $i++ }
  [void]$body.Append((EmitP ($para -join ' ')))
}

# ---------- assemble document.xml ----------
$docXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
'<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
'<w:body>' + $body.ToString() +
'<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>' +
'</w:body></w:document>'
try { [xml]$null = $docXml } catch { throw "document.xml not well-formed: " + $_.Exception.Message }

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Microsoft YaHei"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:line="276" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Microsoft YaHei"/><w:b/><w:color w:val="1F4E79"/><w:sz w:val="36"/><w:szCs w:val="36"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="200" w:after="100"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Microsoft YaHei"/><w:b/><w:color w:val="2E74B5"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="160" w:after="80"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Microsoft YaHei"/><w:b/><w:color w:val="1F4E79"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
</w:styles>
'@
$ctXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
</Types>
'@
$relsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
</Relationships>
'@
$docRelsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@
$coreXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
'<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
'<dc:title>' + (EscText $Title) + '</dc:title><dc:creator>Superpowers Rollout</dc:creator></cp:coreProperties>'

# ---------- write zip ----------
if (Test-Path -LiteralPath $OutputDocx) { Remove-Item -LiteralPath $OutputDocx -Force }
$fs = [System.IO.File]::Create($OutputDocx)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Write-Entry($name, $content) { $e = $zip.CreateEntry($name); $w = New-Object System.IO.StreamWriter($e.Open(), $utf8); $w.Write($content); $w.Close() }
Write-Entry '[Content_Types].xml' $ctXml
Write-Entry '_rels/.rels' $relsXml
Write-Entry 'word/document.xml' $docXml
Write-Entry 'word/styles.xml' $stylesXml
Write-Entry 'word/_rels/document.xml.rels' $docRelsXml
Write-Entry 'docProps/core.xml' $coreXml
$zip.Dispose(); $fs.Close()
Write-Output ("OK -> " + $OutputDocx + "  (" + [math]::Round((Get-Item -LiteralPath $OutputDocx).Length/1KB,1) + " KB)")
