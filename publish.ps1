param(
  [string]$Message = ""
)

if (-not $Message) {
  $Message = "Update site " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

$status = git status --porcelain
if (-not $status) {
  Write-Host "No changes to commit."
  exit 0
}

git add .
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

git commit -m $Message
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

git push
exit $LASTEXITCODE
