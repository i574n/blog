$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

$engine = Join-Path $BlogRoot 'engine'
Invoke-SpiralTests $engine @('html', 'post', 'page', 'pipeline', 'index', 'rss', 'style', 'site', 'build')
Write-Output "BLOG-OK blog/engine"