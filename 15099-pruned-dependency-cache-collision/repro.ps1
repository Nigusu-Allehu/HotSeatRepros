param(
    [string]$DotNet = "dotnet"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Invoke-Restore {
    & $DotNet restore @args --force-evaluate -v quiet
    if ($LASTEXITCODE -ne 0) { throw "Restore failed: $args" }
}

function Get-LibDependency([string]$project) {
    $assetsFile = Join-Path $root "$project\obj\project.assets.json"
    $assets = Get-Content $assetsFile -Raw | ConvertFrom-Json
    return $assets.targets.'net10.0'.'Repro.Lib/1.0.0'.dependencies.PSObject.Properties.Name
}

& (Join-Path $root "setup.ps1") -DotNet $DotNet

Invoke-Restore (Join-Path $root "PrunesFoo\PrunesFoo.csproj")
Invoke-Restore (Join-Path $root "PrunesBar\PrunesBar.csproj")

$expectedFoo = Get-LibDependency "PrunesFoo"
$expectedBar = Get-LibDependency "PrunesBar"

Invoke-Restore (Join-Path $root "Repro.slnx")

$actualFoo = Get-LibDependency "PrunesFoo"
$actualBar = Get-LibDependency "PrunesBar"

Write-Host "Separate restores:"
Write-Host "  PrunesFoo keeps: $expectedFoo"
Write-Host "  PrunesBar keeps: $expectedBar"
Write-Host ""
Write-Host "Solution restore:"
Write-Host "  PrunesFoo keeps: $actualFoo"
Write-Host "  PrunesBar keeps: $actualBar"

if ($actualFoo -eq $expectedFoo -and $actualBar -eq $expectedBar) {
    Write-Host "`nPASS: Each project kept its correct dependency." -ForegroundColor Green
    exit 0
}

Write-Host "`nBUG REPRODUCED: One cached dependency list was reused for both projects." -ForegroundColor Red
exit 1
