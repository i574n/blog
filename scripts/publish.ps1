$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

{ pwsh (Join-Path $SpiralRoot 'scripts/publish-tree.ps1') -Root $BlogRoot } | Invoke-Block
Move-Item (Join-Path $BlogRoot 'dist/index.html') (Join-Path $BlogRoot 'dist/tree.html') -Force
{ pwsh (Join-Path $PSScriptRoot 'generate.ps1') } | Invoke-Block

$built = Join-Path $BlogRoot 'target/build'
foreach ($package in @(Get-ChildItem $built -Directory -ErrorAction Ignore)) {
    $notebooks = Join-Path $package.FullName 'notebooks'
    if (Test-Path $notebooks) {
        $published = Join-Path $BlogRoot "dist/notebooks/$($package.Name)"
        New-Item -ItemType Directory -Force $published | Out-Null
        Copy-Item (Join-Path $notebooks '*') $published -Include '*.ipynb', '*.html', '*.livemd'
    }
}