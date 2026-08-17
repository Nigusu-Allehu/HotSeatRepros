$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
    $consumerProject = '.\Consumer\Consumer.csproj'
    $project = [xml](Get-Content -Raw $consumerProject)
    $itemGroups = @($project.SelectNodes('/Project/ItemGroup'))
    $packageReferences = @($project.SelectNodes('//PackageReference'))
    foreach ($reference in $packageReferences) {
        if ($reference.Include -eq 'Company.Division.Product') {
            [void]$reference.ParentNode.RemoveChild($reference)
        }
    }

    foreach ($itemGroup in $itemGroups) {
        if ($itemGroup.ChildNodes.Count -eq 0) {
            [void]$project.DocumentElement.RemoveChild($itemGroup)
        }
    }

    $project.Save((Resolve-Path $consumerProject))

    foreach ($path in @(
        '.\Consumer\bin',
        '.\Consumer\obj',
        '.\cache\packages\company.division.packagea',
        '.\cache\packages\company.division.packageb',
        '.\cache\packages\company.division.product'
    )) {
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force
        }
    }

    Write-Host 'Consumer and repro-local NuGet caches reset.'
}
finally {
    Pop-Location
}
