$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

{ pwsh (Join-Path $SpiralRoot 'scripts/publish-tree.ps1') -Root $BlogRoot } | Invoke-Block
