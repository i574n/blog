$BlogRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$SpiralRoot = [IO.Path]::GetFullPath((Join-Path $BlogRoot '../spiral'))

function Assert-SpiralBeside {
    if (!(Test-Path (Join-Path $SpiralRoot 'lib/spiral/lib.ps1'))) {
        throw "blog builds against spiral cloned beside it, expected at ${SpiralRoot}: run pwsh scripts/init.ps1"
    }
}

function Get-BlogTargetDir([Parameter(Mandatory)] [string] $Name) {
    $dir = Join-Path $BlogRoot "target/build/$Name"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $dir
}

function Invoke-SpiralTests([Parameter(Mandatory)] [string] $PackageDir, [Parameter(Mandatory)] [string[]] $Modules) {
    $notebooks = Join-Path (Get-BlogTargetDir (Split-Path $PackageDir -Leaf)) 'notebooks'
    New-Item -ItemType Directory -Force $notebooks | Out-Null
    $saved = $env:SPIRAL_CELLS_COMPILER, $env:SPIRAL_CELLS_WARM
    $env:SPIRAL_CELLS_COMPILER, $env:SPIRAL_CELLS_WARM = 'process', '0'
    try {
        foreach ($module in $Modules) {
            $runner = Join-Path $SpiralRoot 'apps/cells/spi/run_notebook.ps1'
            { pwsh -NoProfile -File $runner --path (Join-Path $PackageDir "$module.spi") --output-path (Join-Path $notebooks "$module.spi.ipynb") --no-html } | Invoke-Block
        }
    } finally {
        $env:SPIRAL_CELLS_COMPILER, $env:SPIRAL_CELLS_WARM = $saved
    }
}