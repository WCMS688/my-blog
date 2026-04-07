param(
  [string]$Message = "",
  [switch]$AllowFutureDate,
  [switch]$DryRun,
  [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Args
  )

  $output = & git @Args
  if ($LASTEXITCODE -ne 0) {
    throw "git $($Args -join ' ') failed."
  }

  return @($output)
}

function Get-ChangedEntries {
  $lines = @(Invoke-Git -Args @("status", "--porcelain=v1", "--untracked-files=all"))
  $entries = @()

  foreach ($line in $lines) {
    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }

    $pathText = $line.Substring(3)
    $originalPath = $null

    if ($pathText -like "* -> *") {
      $parts = $pathText -split " -> ", 2
      $originalPath = $parts[0]
      $pathText = $parts[1]
    }

    $entries += [pscustomobject]@{
      IndexStatus   = $line.Substring(0, 1)
      WorktreeStatus = $line.Substring(1, 1)
      Path          = $pathText
      OriginalPath  = $originalPath
      Raw           = $line
    }
  }

  return $entries
}

function Get-EntryChangeKind {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Entry
  )

  if ($Entry.IndexStatus -eq "?" -and $Entry.WorktreeStatus -eq "?") {
    return "add"
  }

  if ($Entry.IndexStatus -eq "A" -or $Entry.WorktreeStatus -eq "A") {
    return "add"
  }

  if ($Entry.IndexStatus -eq "D" -or $Entry.WorktreeStatus -eq "D") {
    return "delete"
  }

  return "update"
}

function Get-TomlScalar {
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [string[]]$Lines,
    [Parameter(Mandatory = $true)]
    [string]$Key
  )

  $pattern = "^\s*$([regex]::Escape($Key))\s*=\s*(.+?)\s*$"
  foreach ($line in $Lines) {
    $match = [regex]::Match($line, $pattern)
    if ($match.Success) {
      $value = $match.Groups[1].Value.Trim()
      if ($value.StartsWith('"') -and $value.EndsWith('"')) {
        return $value.Substring(1, $value.Length - 2)
      }

      return $value
    }
  }

  return $null
}

function Get-PostMetadata {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  $fallbackSlug = [IO.Path]::GetFileNameWithoutExtension($Path)
  $fallbackTitle = $fallbackSlug

  if (-not (Test-Path $Path)) {
    return [pscustomobject]@{
      Path          = $Path
      Slug          = $fallbackSlug
      Title         = $fallbackTitle
      Draft         = $false
      EffectiveDate = $null
    }
  }

  $content = @(Get-Content -Encoding utf8 $Path)
  if ($content.Count -lt 3 -or $content[0].Trim() -ne "+++") {
    return [pscustomobject]@{
      Path          = $Path
      Slug          = $fallbackSlug
      Title         = $fallbackTitle
      Draft         = $false
      EffectiveDate = $null
    }
  }

  $frontMatter = New-Object System.Collections.Generic.List[string]
  for ($i = 1; $i -lt $content.Count; $i++) {
    if ($content[$i].Trim() -eq "+++") {
      break
    }

    $frontMatter.Add($content[$i])
  }

  $title = Get-TomlScalar -Lines $frontMatter -Key "title"
  $slug = Get-TomlScalar -Lines $frontMatter -Key "slug"
  $draftValue = Get-TomlScalar -Lines $frontMatter -Key "draft"
  $publishDate = Get-TomlScalar -Lines $frontMatter -Key "publishDate"
  $dateValue = Get-TomlScalar -Lines $frontMatter -Key "date"

  $draft = $false
  if ($null -ne $draftValue) {
    $draft = $draftValue.Trim().ToLowerInvariant() -eq "true"
  }

  $effectiveDate = $null
  $candidateDate = if ($publishDate) { $publishDate } else { $dateValue }
  if ($candidateDate) {
    $effectiveDate = [DateTimeOffset]::Parse($candidateDate)
  }

  return [pscustomobject]@{
    Path          = $Path
    Slug          = if ($slug) { $slug } else { $fallbackSlug }
    Title         = if ($title) { $title } else { $fallbackTitle }
    Draft         = $draft
    EffectiveDate = $effectiveDate
  }
}

function Add-UniquePath {
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [System.Collections.Generic.List[string]]$List,
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (-not $List.Contains($Path)) {
    $List.Add($Path)
  }
}

function Get-OrCreateGroup {
  param(
    [Parameter(Mandatory = $true)]
    [System.Collections.Specialized.OrderedDictionary]$Groups,
    [Parameter(Mandatory = $true)]
    [string]$Slug
  )

  if (-not $Groups.Contains($Slug)) {
    $Groups[$Slug] = [pscustomobject]@{
      Slug          = $Slug
      Metadata      = $null
      ArticleEntry  = $null
      Paths         = New-Object System.Collections.Generic.List[string]
    }
  }

  return $Groups[$Slug]
}

function Test-FuturePublishDate {
  param(
    [Parameter(Mandatory = $true)]
    [object[]]$Groups,
    [switch]$AllowFuture
  )

  if ($AllowFuture) {
    return
  }

  $now = [DateTimeOffset]::Now
  $issues = @()

  foreach ($group in $Groups) {
    if (-not $group.ArticleEntry -or -not $group.Metadata) {
      continue
    }

    if ($group.Metadata.Draft) {
      continue
    }

    if ($group.Metadata.EffectiveDate -and $group.Metadata.EffectiveDate -gt $now) {
      $issues += [pscustomobject]@{
        Path  = $group.ArticleEntry.Path
        Title = $group.Metadata.Title
        Date  = $group.Metadata.EffectiveDate
      }
    }
  }

  if ($issues.Count -gt 0) {
    Write-Host "Found article(s) with a future publish time. Hugo will hide them by default:" -ForegroundColor Red
    foreach ($issue in $issues) {
      Write-Host " - $($issue.Path) -> $($issue.Title) -> $($issue.Date.ToString('yyyy-MM-dd HH:mm:ss zzz'))" -ForegroundColor Red
    }
    Write-Host "Fix the date/publishDate, mark the post as draft, or rerun with -AllowFutureDate." -ForegroundColor Yellow
    exit 2
  }
}

function Get-GroupCommitMessage {
  param(
    [Parameter(Mandatory = $true)]
    [pscustomobject]$Group
  )

  if ($group.ArticleEntry -and $group.Metadata) {
    $changeKind = Get-EntryChangeKind -Entry $group.ArticleEntry
    switch ($changeKind) {
      "add" { return "Add post: $($group.Metadata.Title)" }
      "delete" { return "Delete post: $($group.Metadata.Slug)" }
      default { return "Update post: $($group.Metadata.Title)" }
    }
  }

  $assetKinds = @()
  foreach ($path in $group.Paths) {
    $entry = $script:EntryMap[$path]
    if ($entry) {
      $assetKinds += Get-EntryChangeKind -Entry $entry
    }
  }

  if ($assetKinds.Count -gt 0 -and ($assetKinds | Where-Object { $_ -ne "add" }).Count -eq 0) {
    return "Add post assets: $($group.Slug)"
  }

  if ($assetKinds.Count -gt 0 -and ($assetKinds | Where-Object { $_ -ne "delete" }).Count -eq 0) {
    return "Delete post assets: $($group.Slug)"
  }

  return "Update post assets: $($group.Slug)"
}

function Invoke-CommitForPaths {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Paths,
    [Parameter(Mandatory = $true)]
    [string]$CommitMessage,
    [switch]$PreviewOnly
  )

  $paths = $Paths | Sort-Object -Unique
  if ($paths.Count -eq 0) {
    return $false
  }

  if ($PreviewOnly) {
    Write-Host "[DryRun] $CommitMessage" -ForegroundColor Cyan
    foreach ($path in $paths) {
      Write-Host "  - $path"
    }
    return $true
  }

  & git add -A -- @paths
  if ($LASTEXITCODE -ne 0) {
    throw "git add failed for: $($paths -join ', ')"
  }

  $staged = @(Invoke-Git -Args (@("diff", "--cached", "--name-only", "--") + $paths))
  if ($staged.Count -eq 0) {
    return $false
  }

  & git commit -m $CommitMessage
  if ($LASTEXITCODE -ne 0) {
    throw "git commit failed."
  }

  return $true
}

$changedEntries = @(Get-ChangedEntries)
if ($changedEntries.Count -eq 0) {
  Write-Host "No changes to commit."
  exit 0
}

$script:EntryMap = @{}
foreach ($entry in $changedEntries) {
  $script:EntryMap[$entry.Path] = $entry
}

$groups = New-Object System.Collections.Specialized.OrderedDictionary
$consumedPaths = New-Object System.Collections.Generic.HashSet[string]

foreach ($entry in $changedEntries) {
  if ($entry.Path -match '^content/posts/[^/\\]+\.md$' -and $entry.Path -notmatch '^content/posts/_index\.md$') {
    $metadata = Get-PostMetadata -Path $entry.Path
    $group = Get-OrCreateGroup -Groups $groups -Slug $metadata.Slug
    $group.Metadata = $metadata
    $group.ArticleEntry = $entry
    Add-UniquePath -List $group.Paths -Path $entry.Path
    $null = $consumedPaths.Add($entry.Path)
  }
}

foreach ($entry in $changedEntries) {
  $assetMatch = [regex]::Match($entry.Path, '^static/uploads/([^/\\]+)/')
  if ($assetMatch.Success) {
    $slug = $assetMatch.Groups[1].Value
    $group = Get-OrCreateGroup -Groups $groups -Slug $slug
    Add-UniquePath -List $group.Paths -Path $entry.Path
    $null = $consumedPaths.Add($entry.Path)
  }
}

$groupList = @($groups.Values)
if ($groupList.Count -gt 0) {
  Test-FuturePublishDate -Groups $groupList -AllowFuture:$AllowFutureDate
}

$commits = New-Object System.Collections.Generic.List[string]

foreach ($group in $groupList) {
  $commitMessage = Get-GroupCommitMessage -Group $group
  $committed = Invoke-CommitForPaths -Paths $group.Paths.ToArray() -CommitMessage $commitMessage -PreviewOnly:$DryRun
  if ($committed) {
    $commits.Add($commitMessage)
  }
}

$sitePaths = New-Object System.Collections.Generic.List[string]
foreach ($entry in $changedEntries) {
  if (-not $consumedPaths.Contains($entry.Path)) {
    Add-UniquePath -List $sitePaths -Path $entry.Path
  }
}

if ($sitePaths.Count -gt 0) {
  $siteMessage = if ($Message) {
    $Message
  } else {
    "Update site files " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
  }

  $siteCommitted = Invoke-CommitForPaths -Paths $sitePaths.ToArray() -CommitMessage $siteMessage -PreviewOnly:$DryRun
  if ($siteCommitted) {
    $commits.Add($siteMessage)
  }
}

if ($commits.Count -eq 0) {
  Write-Host "No staged changes were produced."
  exit 0
}

if ($DryRun) {
  Write-Host ""
  Write-Host "[DryRun] Planned commits:" -ForegroundColor Cyan
  foreach ($commit in $commits) {
    Write-Host " - $commit"
  }
  exit 0
}

if ($NoPush) {
  Write-Host "Commit(s) created. Skipping push because -NoPush was specified."
  exit 0
}

& git push
if ($LASTEXITCODE -ne 0) {
  $currentBranch = (& git branch --show-current).Trim()
  if (-not $currentBranch) {
    $currentBranch = "main"
  }

  Write-Host ""
  Write-Host "Push failed, but local commit(s) were created successfully." -ForegroundColor Yellow
  Write-Host "You can retry later with: git push origin $currentBranch" -ForegroundColor Yellow
}

exit $LASTEXITCODE
