$ErrorActionPreference = 'Continue'

function Emit-SystemMessage($msg) {
  Write-Output (@{ systemMessage = $msg } | ConvertTo-Json -Compress)
}

$repoRoot = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { exit 0 }
Set-Location $repoRoot

$branch = git rev-parse --abbrev-ref HEAD
if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') { exit 0 }

git add -u | Out-Null

$staged = git diff --cached --name-only
if (-not $staged) { exit 0 }

$commitMsg = "Auto-commit from Claude Code session`n`nCo-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git commit -m $commitMsg | Out-Null
if ($LASTEXITCODE -ne 0) {
  Emit-SystemMessage "Auto-push hook: commit failed; nothing pushed."
  exit 0
}

git push origin main | Out-Null
if ($LASTEXITCODE -ne 0) {
  Emit-SystemMessage "Auto-push hook: committed locally but push to origin/main failed. Run 'git push' manually."
  exit 0
}

exit 0
