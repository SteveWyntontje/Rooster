@{
	Root = 'src\Rooster.ps1'
	OutputPath = 'build'
	Package = @{
		Enabled = $true
		Obfuscate = $false
		HideConsoleWindow = $false
		DotNetVersion = 'v4.8.1'
		FileVersion = '2.1.0'
		FileDescription = 'Een programma om je rooster mee te zien.'
		ProductName = 'Rooster'
		ProductVersion = '2.3.0'
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
        