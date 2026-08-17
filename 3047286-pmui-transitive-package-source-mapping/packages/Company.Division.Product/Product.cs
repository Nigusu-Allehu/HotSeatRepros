namespace Company.Division.Product;

public static class Product
{
    public static string Description =>
        $"{Company.Division.PackageA.PackageA.Value} + " +
        Company.Division.PackageB.PackageB.Value;
}
