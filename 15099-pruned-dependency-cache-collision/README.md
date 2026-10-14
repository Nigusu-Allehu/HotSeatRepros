# NuGet/Home #15099 repro

This reproduces a solution-restore cache collision when two projects prune
different dependencies from the same package but retain the same dependency
count.

`Repro.Lib` depends on `Repro.Foo` and `Repro.Bar`:

- `PrunesFoo` removes `Repro.Foo`, so it should retain only `Repro.Bar`.
- `PrunesBar` removes `Repro.Bar`, so it should retain only `Repro.Foo`.

Run with .NET SDK 10.0.300 or later:

```powershell
.\repro.ps1
```

The script first restores each project separately to establish the expected
result in `obj\project.assets.json`. It then restores the solution. When the
bug occurs, both projects receive the same dependency list.

Tracking issue: https://github.com/NuGet/Home/issues/15099
