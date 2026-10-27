$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')
. (Join-Path $SpiralRoot 'lib/spiral/lib.ps1')

$engine = Join-Path $BlogRoot 'app'
if (!(BuildSpiral (Join-Path $engine 'generate.spi') (Join-Path $engine 'generate.rs') 'blog/app/generate')) { throw 'RUST-FAILED blog/engine/generate / compile' }
$manifest = Join-Path $BlogRoot 'generator/Cargo.toml'
{ cargo build --release --manifest-path $manifest } | Invoke-Block
$targetDir = (cargo metadata --format-version 1 --no-deps --manifest-path $manifest | ConvertFrom-Json).target_directory
$exe = Join-Path $targetDir "release/blog-generate$(if ($IsWindows) { '.exe' })"
{ & $exe } | Invoke-Block -Location $BlogRoot
Write-Output "BLOG-GENERATED dist/ ($(@(Get-ChildItem (Join-Path $BlogRoot 'dist') -Recurse -File -Include *.html, *.xml, *.css).Count) site files)"
