Function Import-ICS {
	Param (
		[string]$Url
	)

	try {
		$response = Invoke-WebRequest -Uri $Url
		$icsContent = $response.Content
	}
	catch {
		Write-Error "Kan het .ics-bestand niet downloaden."		
	}

	$events = @()
	$currentEvent = @{}
	$VakTimes = @{}
	foreach ($line in $icsContent -split "`n") {
		$line = $line.Trim()
		if ($line -eq "BEGIN:VEVENT") {
			$currentEvent = @{}
		}
		elseif ($line -eq "END:VEVENT") {
			$events += $currentEvent
		}
		elseif ($line -match "^(?<key>[^:;]+)(;TZID=(?<tzid>[^:;]+))?:(?<value>.+)$") {
			$key = $matches['key']
			$value = $matches['value']
			if ($matches['tzid']) {
				$currentEvent["TZID"] = $matches['tzid']
			}
			$currentEvent[$key] = $value
		}
	}

	$lessonStartTimes = @(
		"08:10", "09:00", "09:50",
		"11:00", "11:50",
		"13:10", "14:00", "14:50", "15:40"
	)

	$lessonEndTimes = @(
		"09:00", "09:50", "10:40",
		"11:50", "12:40",
		"14:00", "14:50", "15:40", "16:30"
	)

	$days = @{
		"Ma" = @()
		"Di" = @()
		"Wo" = @()
		"Do" = @()
		"Vr" = @()
	}

	$Vakken = @()
	foreach ($event in $events) {
		if (-not $event.ContainsKey("SUMMARY") -or -not $event.ContainsKey("DTSTART") -or -not $event.ContainsKey("DTEND")) {
			continue
		}
		$match = [regex]::Match($summary, '(?<lokaal>[a-z0-9]{1,4}) - (?<klas>[a-z0-9]{1,2}?)(?<vak>[a-zA-Z]{2,8})')
		$extractedLokaal = $match.Groups['lokaal'].Value
		$extractedKlas   = $match.Groups['klas'].Value
		$extractedVak    = $match.Groups['vak'].Value
		$summary = $event["SUMMARY"]

		if (-not $Vakken.Contains($extractedVak)) {
			$Vakken += $extractedVak
		}
		
		$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
		$startTime = $startDate.TimeOfDay
		$endDate = [datetime]::ParseExact($event["DTEND"], "yyyyMMddTHHmmssZ", $null)
		$endTime = $endDate.TimeOfDay

		$lessonSlot = @{}
		for ($i = 0; $i -lt $lessonStartTimes.Count - 1; $i++) {
			$testingStartTime = [datetime]::ParseExact($lessonStartTimes[$i], "HH:mm", $null)
			$testingEndTime = [datetime]::ParseExact($lessonEndTimes[$i], "HH:mm", $null)
			if ($startTime -eq $testingStartTime.TimeOfDay -and $endTime -eq $testingEndTime.TimeOfDay) {
				$lessonSlot[$i] = ($i + 1)
			}
		}

		if (-not $lessonSlot) {
			continue
		}

		$dayShort = $startDate.ToString("ddd", [System.Globalization.CultureInfo]::GetCultureInfo("nl-NL"))
		$dayShort = $dayShort.ToLower()
		$dag = $dayShort.Substring(0, 1).ToUpper() + $dayShort.Substring(1)

		$uur = "$($lessonSlot.Values[0])e"
		$slot = "${dag}: $uur"
		if (-not $VakTimes.ContainsKey($extractedVak)) {
			$VakTimes[$extractedVak] = @()
		}
		if (-not $VakTimes[$extractedVak].Contains($slot)) {
			$VakTimes[$extractedVak] += $slot
		}

		$dayCode = $startDate.ToString("ddd", [System.Globalization.CultureInfo]::GetCultureInfo("nl-NL")).ToUpperInvariant().Substring(0, 2)

		if ($days.ContainsKey($dayCode)) {
			if (-not $days[$dayCode].Contains($extractedVak)) {
				$days[$dayCode] += $extractedVak
			}
		}
	}
	
	$Global:Maandag = $days["Ma"]
	$Global:Dinsdag = $days["Di"]
	$Global:Woensdag = $days["Wo"]
	$Global:Donderdag = $days["Do"]
	$Global:Vrijdag = $days["Vr"]

	foreach ($vak in $VakTimes.Keys) {
		if ($vak) {
			Set-Variable -Name $vak -Value $VakTimes[$vak] -Scope Global
		}
		else {
			continue
		}
	}

	$Vakken = $Vakken | Sort-Object
	return $Vakken
}
Function New-Table {
	Param (
		[hashtable]$Days
	)

	if (-not $Days) {
		throw "Error #3"
		return @()
	}

	$table = @()

	$dayrow = "  Dag	|  Ma  ｜  Di  ｜  Wo  ｜  Do  ｜  Vr  ｜"
	$seprow1 = "════════|═══════════════════════════════════════"
	$seprow2 = "⎯⎯⎯⎯⎯⎯⎯⎯|⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"

	$table += $dayrow
	$table += $seprow1

	for ($hour = 1; $hour -le 9; $hour++) {
		$row = "   $hour" + "e   |"
		foreach ($day in @("Ma", "Di", "Wo", "Do", "Vr")) {
			if ($Days.ContainsKey($day) -and $Days[$day].Count -ge $hour) {
				if ($($Days[$day][$hour - 1]).Length -eq 3) {
					$row += " $($Days[$day][$hour - 1])  ｜"
				}
				elseif ($($Days[$day][$hour - 1]).Length -eq 4) {
					$row += " $($Days[$day][$hour - 1]) ｜"
				}
				else {
					$row += " $($Days[$day][$hour - 1])｜"
				}
			}
			else {
				$row += "      ｜"
			}
		}
		$table += $row
		if ($hour -lt 9) {
			$table += $seprow2
		}
	}
	return $table
}

if ($isWindows) {
	Test-Path "HKCU:\Software\rooster" | Out-Null || throw "Error #3`nVoer eerst `"rooster --register`"uit`n" && set-variable icsUrl (Get-ItemProperty -Path "HKCU:\Software\rooster" -Name "icsUrl").icsUrl
}
elseif ($isLinux) {
	Test-Path "~/.config/rooster/icsUrl" | Out-Null || throw "Error #3`nVoer eerst `"rooster --register`"uit`n" && set-variable icsUrl (Get-Content -Path ~/.config/rooster/icsUrl)
}

$Vakken = Import-ICS -Url $icsUrl

$Days = @{
	"Ma" = $Maandag
	"Di" = $Dinsdag
	"Wo" = $Woensdag
	"Do" = $Donderdag
	"Vr" = $Vrijdag
}

$row = New-Table -Days $Days

$Dagen = @("Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag")
$DagCodes = @("Ma", "Di", "Wo", "Do", "Vr")
$DagMap = @{
	"Ma" = "Maandag"
	"Di" = "Dinsdag"
	"Wo" = "Woensdag"
	"Do" = "Donderdag"
	"Vr" = "Vrijdag"
}

if ($Args[0] -eq "--help" -Or $Args[0] -eq "-h") {
	write-host "ROOSTER [-d <dag> [-u <uur>]] [-r] [-s <vak>] [--register [<URL>]] [-h]"
	write-host '-r, --rooster	Geeft het rooster weer.'
	write-host '-s, --search	Zoekt wanneer een vak is.'
	write-host '-d		De dag. Als je geen uur opgeeft, worden alle uren van die dag weergegeven.'
	write-host '-u		Het uur.'
	write-host '--register		Registreert jouw Somtoday.'
	write-host '-h, --help		Toont deze helptekst.'
	write-host 'Dagen: Ma, Di, Wo, Do, Vr.'
	write-host 'Vakken: Is afhankelijk van wat je zelf hebt. '
	write-host 'Error #1 betekent "Geen Les Hier".'
	write-host 'Error #2 betekent "Verkeerde argumenten".'
	write-host 'Error #3 betekent "Algemene Fout".'
}
elseif ($Args[0] -eq "-d") {
	if ($DagMap.ContainsKey($Args[1])) {
		$SelectedDag = $DagMap[$Args[1]]
		if ($Dagen -contains $SelectedDag) {
			if ($Args.Count -eq 2) {
				$DayArray = Get-Variable -Name $SelectedDag -ValueOnly
				for ($Counter = 1; $Counter -le 9; $Counter++) {
					Write-Host $Counter"e: " -NoNewline
					Write-Host $DayArray[$Counter - 1]
				}
			}
			elseif ($Args.Count -eq 4 -and $Args[2] -eq "-u" -and $Args[3] -match "^[1-9]$") {
				$DayArray = Get-Variable -Name $SelectedDag -ValueOnly
				$HourIndex = [int]$Args[3] - 1
				$HourValue = $DayArray[$HourIndex]
				if ($HourValue -eq "Error #1") {
					throw $HourValue
				}
				else {
					Write-Host $HourValue
				}
			}
			else {
				throw "Error #2"
			}
		}
		else {
			throw "Error #3"
		}
	}
	else {
		throw "Error #2"
	}
}
elseif ($Args[0] -eq "-s" -Or $Args[0] -eq "--search") {
	[int]$NietVakCount = 0
	[int]$WelVakCount = 0
	[int]$VakkenCounter = 0
	while ($VakkenCounter -le $Vakken.count) {
		if ($Args[1] -ne $Vakken[$VakkenCounter]) {
			$NietVakCount++
		}
		else {
			$WelVakCount++
		}
		$VakkenCounter++
	}
	if ($WelVakCount -eq 1) {
		[int]$SearchCounter = 0
		while ($SearchCounter -le $($Args[1]).Length) {
			foreach ($Vak in $Vakken) {
				if ($Args[1] -eq $Vak) {
					write-host $(Get-Variable -Name $Args[1] -ValueOnly)[$SearchCounter]
					$SearchCounter++
				}
			}
		}
	}
}
elseif ($Args[0] -eq "-r" -Or $Args[0] -eq "--rooster") {
	for ($i = 0; $i -lt 19; $i++) {
		write-host $row[$i]
	}
	write-host `n -NoNewline
}
elseif ($Args[0] -eq "--register") {
	if ($Args.Count -eq 2) {
		if ($isWindows) {
			New-ItemProperty -Path "HKCU:\Software\rooster" -Name "icsUrl" -Value $Args[1] -PropertyType String -Force | Out-Null
		}
		elseif ($isLinux) {
			New-Item -Path ~/.config/rooster -Name "icsUrl" -ItemType "File" -Value $Args[1] | Out-Null
		}
	}
	else {
		Write-Host 'Ga naar Somtoday. Open de instellingen. Ga naar "Agenda" en kopieer de link nadat je op "Aan de slag" hebt geklikt.'
		Write-Host '(Als je geen Somtoday gebruikt maar een andere ELO moet je daarin een iCalender link zien te vinden.)'
		$URLInput = Read-Host "Plak hier de link"
		if ($URLInput -notmatch "(https://.+)|(http://.+)") {
			Write-Host "Voer hier alleen een link in."
		}
		elseif ($URLInput -eq "") {
			Write-Host "Plak hier a.u.b. de link in."
		}
		else {
			if ($isWindows) {
				New-Item -ItemType Directory -Path HKCU:\Software\rooster -Force
				New-ItemProperty -Path "HKCU:\Software\rooster" -Name "icsUrl" -Value $URLInput -PropertyType String -Force | Out-Null && Write-Host "Link succesvol geregistreerd." -ForegroundColor Green || Write-Host "Er is een fout opgetreden bij het registreren van de link."
			}
			elseif ($isLinux) {
				New-Item -ItemType Directory -Path ~/.config/rooster -Force | Out-Null
				New-Item -Path "~/.config/rooster" -Name "icsUrl" -ItemType File -Value $URLInput -Force | Out-Null && Write-Host "Link succesvol geregistreerd." -ForegroundColor Green || Write-Host "Er is een fout opgetreden bij het registreren van de link."
			}
		}
	}
}
else {
	throw "Error #2"
	Write-Host 'Probeer "./rooster --help" in je terminal (waarschijnlijk cmd) uit te voeren.'
	Write-Host ""
	if ($isWindows) {
		cmd /c pause
	}
	elseif ($isLinux) {
		echo "Press any key to continue..."; bash -c "read -n1"
	}
	return 2
}
