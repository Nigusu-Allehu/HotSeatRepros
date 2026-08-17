$dotnetName = if ($IsWindows) { 'dotnet.exe' } else { 'dotnet' }

if ($env:DOTNET_ROOT) {
    $dotnetPath = Join-Path $env:DOTNET_ROOT $dotnetName
    if (Test-Path $dotnetPath) {
        return $dotnetPath
    }
}

$dotnetCommand = Get-Command dotnet -ErrorAction Stop
return $dotnetCommand.Source
