param(
  [Parameter(Mandatory = $true)][string]$Title,
  [string]$OriginalRoughPrompt,
  [string]$OriginalRoughPromptPath,
  [string]$EngineeredBrief,
  [string]$EngineeredBriefPath,
  [string]$ContextSnapshot = "",
  [string]$ContextSnapshotPath,
  [string[]]$RelevantPaths = @(),
  [string[]]$AssumptionsGaps = @(),
  [ValidateSet("coding", "research", "writing", "planning", "other")][string]$TaskType = "other",
  [ValidateSet("approved-save-only", "approved-save-and-run")][string]$Status = "approved-save-only",
  [ValidateSet("not-run", "current-agent", "fresh-agent")][string]$RunMode = "not-run",
  [string]$ProjectRoot = "",
  [Parameter(Mandatory = $true)][string]$Cwd,
  [string]$ApprovalChoice = "Approve and save only",
  [string]$RecommendedMode = "not-applicable",
  [string]$CodexHome = "",
  [string]$CreatedAt = "",
  [string]$Id = ""
)

$ErrorActionPreference = "Stop"

function Get-RequiredText {
  param([string]$Value, [string]$Path, [string]$Name)
  if ($Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
      throw "$Name path does not exist: $Path"
    }
    return (Get-Content -LiteralPath $Path -Raw)
  }
  if ($Value) { return $Value }
  throw "$Name is required. Pass -$Name or -${Name}Path."
}

function New-Slug {
  param([string]$Text)
  $slug = $Text.ToLowerInvariant() -replace "[^a-z0-9]+", "-"
  $slug = $slug -replace "^-+", "" -replace "-+$", ""
  if (-not $slug) { return "prompt-brief" }
  if ($slug.Length -gt 72) { return $slug.Substring(0, 72).TrimEnd("-") }
  return $slug
}

function Escape-IndexTitle {
  param([string]$Text)
  return (($Text -replace "[`r`n]+", " ").Trim() -replace "\\", "\\" -replace "\[", "\[" -replace "\]", "\]" -replace "\|", "\|")
}

function Convert-ToBullets {
  param([string[]]$Items)
  if (-not $Items -or $Items.Count -eq 0) { return "- none" }
  return (($Items | ForEach-Object { "- `$_" }) -join "`r`n")
}

function Ensure-Index {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path -PathType Leaf) { return }
  $template = @(
    "# Prompt Brief Library",
    "",
    "## Recent Entries",
    "",
    "## By Task Type",
    "",
    "### Coding",
    "",
    "### Research",
    "",
    "### Writing",
    "",
    "### Planning",
    "",
    "### Other"
  ) -join "`r`n"
  Set-Content -LiteralPath $Path -Value $template -Encoding UTF8
}

function Add-IndexLine {
  param([string]$Path, [string]$Heading, [string]$EntryLine, [string]$EntryId)
  $content = Get-Content -LiteralPath $Path -Raw
  if ($content.Contains($EntryLine)) { return }
  $lines = [System.Collections.Generic.List[string]]::new()
  foreach ($existingLine in ($content -split "`r?`n")) { [void]$lines.Add($existingLine) }
  $idx = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq $Heading) { $idx = $i; break }
  }
  if ($idx -lt 0) { throw "Missing index heading '$Heading' in $Path" }
  $lines.Insert($idx + 1, $EntryLine)
  Set-Content -LiteralPath $Path -Value ($lines -join "`r`n") -Encoding UTF8
}

$rough = Get-RequiredText -Value $OriginalRoughPrompt -Path $OriginalRoughPromptPath -Name "OriginalRoughPrompt"
$brief = Get-RequiredText -Value $EngineeredBrief -Path $EngineeredBriefPath -Name "EngineeredBrief"
if ($ContextSnapshotPath) { $ContextSnapshot = Get-Content -LiteralPath $ContextSnapshotPath -Raw }

$now = Get-Date
if (-not $CreatedAt) { $CreatedAt = $now.ToString("o") }
$slug = New-Slug -Text $Title
if (-not $Id) { $Id = "$($now.ToString("yyyyMMdd-HHmmss"))-$slug" }
$fileStamp = $now.ToString("yyyy-MM-dd_HHmmss")
if ($Id -match "^(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})-(.+)$") {
  $fileStamp = "$($Matches[1])-$($Matches[2])-$($Matches[3])_$($Matches[4])$($Matches[5])$($Matches[6])"
  $slug = $Matches[7]
}
$filename = "${fileStamp}_${slug}.md"

$workspaceRoot = if ($ProjectRoot) { $ProjectRoot } else { $Cwd }
$workspaceLibrary = Join-Path $workspaceRoot ".codex\prompt-brief-library"
if (-not $CodexHome) {
  $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}
$globalLibrary = Join-Path $CodexHome "prompt-brief-library"
New-Item -ItemType Directory -Force -Path $workspaceLibrary, $globalLibrary | Out-Null

$workspaceLabel = Split-Path -Leaf $workspaceRoot
$escapedTitle = Escape-IndexTitle -Text $Title
$bt = [char]96
$relevantBlock = Convert-ToBullets -Items $RelevantPaths
$assumptionsBlock = Convert-ToBullets -Items $AssumptionsGaps

function Write-PromptFile {
  param([string]$Library, [string]$SourceLibrary)
  $path = Join-Path $Library $filename
  if (Test-Path -LiteralPath $path -PathType Leaf) { return $path }
  $body = @(
    "---",
    "id: `"$Id`"",
    "title: `"$Title`"",
    "created_at: `"$CreatedAt`"",
    "task_type: `"$TaskType`"",
    "status: `"$Status`"",
    "project_root: `"$ProjectRoot`"",
    "cwd: `"$Cwd`"",
    "run_mode: `"$RunMode`"",
    "source_library: `"$SourceLibrary`"",
    "---",
    "",
    "# $Title",
    "",
    "## Original Rough Prompt",
    "",
    $rough,
    "",
    "## Engineered Brief",
    "",
    $brief,
    "",
    "## Context Snapshot",
    "",
    $ContextSnapshot,
    "",
    "## Relevant Paths / Materials",
    "",
    $relevantBlock,
    "",
    "## Assumptions / Gaps",
    "",
    $assumptionsBlock,
    "",
    "## Approval / Execution Decision",
    "",
    "- Approval choice: $($bt)$ApprovalChoice$($bt)",
    "- Run mode: $($bt)$RunMode$($bt)",
    "- Recommended mode at approval time: $($bt)$RecommendedMode$($bt)"
  ) -join "`r`n"
  Set-Content -LiteralPath $path -Value $body -Encoding UTF8
  return $path
}

$workspaceFile = Write-PromptFile -Library $workspaceLibrary -SourceLibrary "workspace-local"
$globalFile = Write-PromptFile -Library $globalLibrary -SourceLibrary "user-global"

$workspaceIndex = Join-Path $workspaceLibrary "index.md"
$globalIndex = Join-Path $globalLibrary "index.md"
Ensure-Index -Path $workspaceIndex
Ensure-Index -Path $globalIndex

$recentWorkspace = "- $($bt)$CreatedAt$($bt) | $($bt)$TaskType$($bt) | $($bt)$Status$($bt) | [$escapedTitle](./$filename) | $($bt)$workspaceLabel$($bt) <!-- prompt-brief:id=$Id -->"
$recentGlobal = "- $($bt)$CreatedAt$($bt) | $($bt)$TaskType$($bt) | $($bt)$Status$($bt) | [$escapedTitle](./$filename) | $($bt)$workspaceLabel$($bt) | $($bt)$workspaceRoot$($bt) <!-- prompt-brief:id=$Id -->"
$typeHeading = "### " + ($TaskType.Substring(0, 1).ToUpperInvariant() + $TaskType.Substring(1))
$typeWorkspace = "- $($bt)$CreatedAt$($bt) | $($bt)$Status$($bt) | [$escapedTitle](./$filename) <!-- prompt-brief:id=$Id -->"
$typeGlobal = "- $($bt)$CreatedAt$($bt) | $($bt)$Status$($bt) | [$escapedTitle](./$filename) | $($bt)$workspaceRoot$($bt) <!-- prompt-brief:id=$Id -->"

Add-IndexLine -Path $workspaceIndex -Heading "## Recent Entries" -EntryLine $recentWorkspace -EntryId $Id
Add-IndexLine -Path $workspaceIndex -Heading $typeHeading -EntryLine $typeWorkspace -EntryId $Id
Add-IndexLine -Path $globalIndex -Heading "## Recent Entries" -EntryLine $recentGlobal -EntryId $Id
Add-IndexLine -Path $globalIndex -Heading $typeHeading -EntryLine $typeGlobal -EntryId $Id

[pscustomobject]@{
  id = $Id
  workspace_file = $workspaceFile
  global_file = $globalFile
  workspace_index = $workspaceIndex
  global_index = $globalIndex
} | ConvertTo-Json
