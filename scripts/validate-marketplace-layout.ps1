param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$sharedRequiredFiles = @(
  "SKILL.md",
  "agents\openai.yaml",
  "references\shumer-agent-briefing.md",
  "references\prompt-library-format.md"
)

$skills = @(
  @{ Name = "prompt-brief"; ExtraFiles = @() },
  @{ Name = "prompt-brief-2"; ExtraFiles = @() },
  @{ Name = "prompt-brief-3"; ExtraFiles = @("scripts\save-approved-brief.ps1") }
)

foreach ($skill in $skills) {
  $skillName = $skill.Name
  $skillRoot = Join-Path $RepoRoot "skills\$skillName"
  $requiredFiles = @($sharedRequiredFiles + $skill.ExtraFiles)

  foreach ($relativePath in $requiredFiles) {
    $packagePath = Join-Path $skillRoot $relativePath

    if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
      throw "Missing package file: skills/$skillName/$relativePath"
    }
  }

  $skillMd = Get-Content -LiteralPath (Join-Path $skillRoot "SKILL.md") -Raw
  if ($skillMd -notmatch "(?s)^---\s*.*?name:\s*$([regex]::Escape($skillName))\s*.*?description:\s*.+?\s*---") {
    throw "Package SKILL.md is missing valid $skillName frontmatter."
  }
}

foreach ($relativePath in $sharedRequiredFiles) {
  $rootPath = Join-Path $RepoRoot $relativePath
  $packagePath = Join-Path $RepoRoot "skills\prompt-brief\$relativePath"

  if (-not (Test-Path -LiteralPath $rootPath -PathType Leaf)) {
    throw "Missing root skill file: $relativePath"
  }

  $rootContent = (Get-Content -LiteralPath $rootPath -Raw) -replace "`r`n", "`n"
  $packageContent = (Get-Content -LiteralPath $packagePath -Raw) -replace "`r`n", "`n"

  if ($rootContent -ne $packageContent) {
    throw "Root prompt-brief copy is out of sync: $relativePath"
  }
}

Write-Host "Package layout OK: prompt-brief, prompt-brief-2, and prompt-brief-3 are present and valid."
