param(
    [string]$DotNet = "dotnet"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$feed = Join-Path $root "artifacts\feed"

New-Item -ItemType Directory -Force -Path $feed | Out-Null

& $DotNet pack (Join-Path $root "PackageSources\Repro.Foo\Repro.Foo.csproj") -o $feed -v quiet
if ($LASTEXITCODE -ne 0) { throw "Failed to pack Repro.Foo." }

& $DotNet pack (Join-Path $root "PackageSources\Repro.Bar\Repro.Bar.csproj") -o $feed -v quiet
if ($LASTEXITCODE -ne 0) { throw "Failed to pack Repro.Bar." }

& $DotNet pack (Join-Path $root "PackageSources\Repro.Lib\Repro.Lib.csproj") -o $feed -v quiet
if ($LASTEXITCODE -ne 0) { throw "Failed to pack Repro.Lib." }
