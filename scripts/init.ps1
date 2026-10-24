$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot 'common.ps1')

if (!(Test-Path (Join-Path $SpiralRoot '.git'))) {
    $url = git -C $BlogRoot ls-remote --get-url
    $owner = ($url -split '/' | Select-Object -Last 2 | Select-Object -First 1) -replace '\.git$', ''
    $domain = ($url -split '/' | Select-Object -Last 3 | Select-Object -First 1)
    git clone --recurse-submodules "https://$domain/$owner/spiral.git" $SpiralRoot
    if ($LASTEXITCODE -ne 0) { throw "init.ps1 / git clone spiral failed (exit code $LASTEXITCODE)" }
}
Assert-SpiralBeside
. (Join-Path $SpiralRoot 'scripts/core.ps1')

{ pwsh (Join-Path $SpiralRoot 'scripts/init-app-build.ps1') -fast 1 } | Invoke-Block