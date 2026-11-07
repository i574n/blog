$ErrorActionPreference = "Stop"

pwsh (Join-Path $PSScriptRoot 'init.ps1')
if ($LASTEXITCODE -ne 0) { throw "workflow.ps1 / init failed (exit code $LASTEXITCODE)" }
pwsh (Join-Path $PSScriptRoot 'build.ps1')
if ($LASTEXITCODE -ne 0) { throw "workflow.ps1 / build failed (exit code $LASTEXITCODE)" }
