$ErrorActionPreference = 'Stop'

$DotNet = & (Join-Path $PSScriptRoot 'Get-DotNetPath.ps1')

Push-Location $PSScriptRoot
try {
    & .\reset.ps1
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    & $DotNet add .\Consumer\Consumer.csproj package Company.Division.Product `
        --version 1.0.0 --source .\feeds\nuget-division
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    & $DotNet restore .\Consumer\Consumer.csproj --configfile .\NuGet.Config
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    & $DotNet list .\Consumer\Consumer.csproj package --include-transitive
}
finally {
    Pop-Location
}
