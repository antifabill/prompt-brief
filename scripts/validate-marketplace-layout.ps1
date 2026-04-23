param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$skillRoot = Join-Path $RepoRoot "skills\prompt-brief"
$requiredFiles = @(
  "SKILL.md",
  "agents\openai.yaml",
  "references\shumer-agent-briefing.md",
  "references\prompt-library-format.md"
)

foreach ($relativePath in $requiredFiles) {
  $rootPath = Join-Path $RepoRoot $relativePath
  $marketplacePath = Join-Path $skillRoot $relativePath

  if (-not (Test-Path -LiteralPath $rootPath -PathType Leaf)) {
    throw "Missing root skill file: $relativePath"
  }

  if (-not (Test-Path -LiteralPath $marketplacePath -PathType Leaf)) {
    throw "Missing marketplace skill file: skills/prompt-brief/$relativePath"
  }

  $rootHash = (Get-FileHash -LiteralPath $rootPath -Algorithm SHA256).Hash
  $marketplaceHash = (Get-FileHash -LiteralPath $marketplacePath -Algorithm SHA256).Hash

  if ($rootHash -ne $marketplaceHash) {
    throw "Marketplace copy is out of sync: $relativePath"
  }
}

$skillMd = Get-Content -LiteralPath (Join-Path $skillRoot "SKILL.md") -Raw
if ($skillMd -notmatch "(?s)^---\s*.*?name:\s*prompt-brief\s*.*?description:\s*.+?\s*---") {
  throw "Marketplace SKILL.md is missing valid prompt-brief frontmatter."
}

Write-Host "Marketplace layout OK: skills/prompt-brief/SKILL.md and bundled files are present and in sync."
