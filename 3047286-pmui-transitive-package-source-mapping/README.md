# PM UI transitive Package Source Mapping repro

This repository reproduces a Visual Studio Package Manager UI failure involving
overlapping Package Source Mapping prefixes. It uses generated local file feeds
and does not require access to private packages or services.

## Scenario

`Company.Division.Product` depends on:

- `Company.Division.PackageA`
- `Company.Division.PackageB`

All three packages exist only in the generated `nuget-division` feed. An
unrelated `Company.Placeholder` package exists only in `nuget-company`.

`NuGet.Config` contains these overlapping mappings:

```xml
<packageSource key="nuget-division">
  <package pattern="Company.Division.*" />
</packageSource>
<packageSource key="nuget-company">
  <package pattern="Company.*" />
</packageSource>
```

NuGet's documented precedence rules say the longer `Company.Division.*` prefix
wins for all three division packages.

## Prerequisites

- Visual Studio 18.9 with the .NET desktop development workload
- .NET SDK 10
- PowerShell

## Create the local feeds

From a PowerShell prompt in this directory, run:

```powershell
.\setup.ps1
```

This packs the four projects and creates two ignored local feeds under
`feeds\`. Run this once after cloning.

## Reproduce in Visual Studio

1. Run `.\reset.ps1`.
2. Open `PMUI.PackageSourceMapping.TransitiveDependencies.Repro.sln`.
3. Open **Manage NuGet Packages for Solution**.
4. Select `nuget-division` from the **Package source** dropdown. Do not select
   **All**.
5. Enable **Show preview window**.
6. Browse for `Company.Division.Product` version 1.0.0.
7. Select the `Consumer` project and click **Install**.
8. Record the source mappings shown in the preview, then apply the installation.
9. Open the **Package Manager** output and inspect the restore failure.

## Actual result

The top-level `Company.Division.Product` package is found in `nuget-division`,
but PM UI searches for its two `Company.Division.*` dependencies only in
`nuget-company`. Restore fails with NU1101 and reports that `nuget-division`
was not considered. PM UI rolls back the operation, so no `PackageReference`
remains in `Consumer.csproj`.

## Expected result

`Company.Division.*` is more specific than `Company.*`, so Product, PackageA,
and PackageB should all restore from `nuget-division`. Installation should
succeed and add a `PackageReference` for Product to `Consumer.csproj`.

## CLI control

Reset and run the equivalent command-line installation:

```powershell
.\verify-cli.ps1
```

The CLI path succeeds with the same package graph and mapping configuration.
This isolates the failure to the PM UI single-source installation path.

To repeat either test, run `.\reset.ps1` first. The script removes the Product
reference and clears only this repro's generated output and package cache.
