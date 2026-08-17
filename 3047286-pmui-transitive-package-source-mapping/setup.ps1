$ErrorActionPreference = 'Stop'

$DotNet = & (Join-Path $PSScriptRoot 'Get-DotNetPath.ps1')

$divisionFeed = Join-Path $PSScriptRoot 'feeds\nuget-division'
$companyFeed = Join-Path $PSScriptRoot 'feeds\nuget-company'
$packageOutput = Join-Path $PSScriptRoot 'artifacts\packages'

foreach ($path in @($divisionFeed, $companyFeed, $packageOutput)) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

$projects = @(
    'packages\Company.Division.PackageA\Company.Division.PackageA.csproj',
    'packages\Company.Division.PackageB\Company.Division.PackageB.csproj',
    'packages\Company.Division.Product\Company.Division.Product.csproj',
    'packages\Company.Placeholder\Company.Placeholder.csproj'
)

Push-Location $PSScriptRoot
try {
    foreach ($project in $projects) {
        & $DotNet restore $project --configfile .\NuGet.Config
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }

        & $DotNet pack $project --no-restore --configuration Release `
            --output $packageOutput
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }
    }

    Copy-Item "$packageOutput\Company.Division.*.1.0.0.nupkg" $divisionFeed -Force
    Copy-Item "$packageOutput\Company.Placeholder.1.0.0.nupkg" $companyFeed -Force

    Write-Host 'Local feeds created:'
    Write-Host "  Division: $divisionFeed"
    Write-Host "  Company:  $companyFeed"
}
finally {
    Pop-Location
}
