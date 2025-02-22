@{
    Root = 'c:\Users\wynto\Projects\PowerShell Stuff\Rooster\Source\Rooster.ps1'
    OutputPath = 'c:\Users\wynto\Projects\PowerShell Stuff\Rooster\Build\Exe'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.6.2'
        FileVersion = '2.1.0'
        FileDescription = 'Een programma om je rooster mee te zien.'
        ProductName = 'Rooster'
        ProductVersion = '2.1.0'
        Copyright = 'Wynton de Kort'
        RequireElevation = $false
        ApplicationIconPath = ''
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
        