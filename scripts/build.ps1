$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

Invoke-SpiralTests $BlogRoot @('engine/html', 'engine/post', 'engine/page', 'engine/index', 'engine/rss', 'engine/style', 'engine/site', 'posts/showcase', 'engine/build')
Write-Output "BLOG-OK blog/engine"
