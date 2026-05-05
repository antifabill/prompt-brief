param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
)

$ErrorActionPreference = "Stop"

$skillRoot = Join-Path $RepoRoot "skills\prompt-brief"
$requiredFiles = @(
  "SKILL.md",
  "agents\openai.yaml",
  "references\shumer-agent-briefing.md",
  "references\prompt-library-format.md",
  "scripts\validate-marketplace-layout.ps1",
  "scripts\save-approved-brief.ps1"
)

foreach ($relativePath in $requiredFiles) {
  $packagedPath = Join-Path $skillRoot $relativePath

  if (-not (Test-Path -LiteralPath $packagedPath -PathType Leaf)) {
    throw "Missing canonical skill file: skills/prompt-brief/$relativePath"
  }
}

$skillMd = Get-Content -LiteralPath (Join-Path $skillRoot "SKILL.md") -Raw
if ($skillMd -notmatch "(?s)^---\s*.*?name:\s*prompt-brief\s*.*?description:\s*.+?\s*---") {
  throw "Packaged SKILL.md is missing valid prompt-brief frontmatter."
}

Write-Host "Package layout OK: skills/prompt-brief/SKILL.md and bundled files are present."
