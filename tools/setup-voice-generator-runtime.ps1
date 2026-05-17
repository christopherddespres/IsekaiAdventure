$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$linkPath = Join-Path $repoRoot "node_modules"
$targetPath = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\node\node_modules"

if (-not (Test-Path -LiteralPath $targetPath)) {
    throw "Codex bundled node_modules was not found at: $targetPath"
}

if (Test-Path -LiteralPath $linkPath) {
    Write-Output "node_modules already exists: $linkPath"
    return
}

New-Item -ItemType Junction -Path $linkPath -Target $targetPath | Out-Null
Write-Output "Created node_modules junction -> $targetPath"
