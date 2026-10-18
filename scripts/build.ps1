$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

$engine = Join-Path $BlogRoot 'engine'
Invoke-SpiralTests $engine @('html', 'post', 'page', 'index', 'rss', 'style', 'site', 'showcase', 'build')
Write-Output "BLOG-OK blog/engine"