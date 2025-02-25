@{
	Root = '/home/wynto/Rooster/Source/Rooster.ps1'
	OutputPath = '/home/wynto/Rooster/Build/Ubuntu x64'
	Package = @{
		Enabled = $true
		Obfuscate = $false
		HideConsoleWindow = $false
		DotNetVersion = 'v4.8.1'
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
        