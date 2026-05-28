Function Import-ICS {
	Param (
		[string]$Url
	)

	try {
		$response = Invoke-WebRequest -Uri $Url
		$icsContent = $response.Content
	}
	catch {
		Write-Host "Kan het .ics-bestand niet downloaden." -ForegroundColor Red
		return
	}

	Write-Debug $icsContent
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

	$lessonTimes = @(
		"08:10", "09:00", "09:50", "10:40",
		"11:00", "11:50", "12:40",
		"13:10", "14:00", "14:50", "15:40", "16:30"
	)

	
	$days = @{
		"MO" = @()
		"TU" = @()
		"WE" = @()
		"TH" = @()
		"FR" = @()
	}

	$Vakken = @()
	foreach ($event in $events) {
		if (-not $event.ContainsKey("SUMMARY") -or -not $event.ContainsKey("DTSTART")) {
			continue
		}

		$summary = $event["SUMMARY"]
		$extractedLokaal = ([regex]::Match($summary, '([a-z0-9]{1,4})')).Groups[1].Value
		$extractedKlas = ([regex]::Match($summary, "$extractedLokaal - ([a-z0-9]{2})")).Groups[1].Value
		$extractedVak = ([regex]::Match($summary, "$extractedKlas([a-zA-Z]{2,8})")).Groups[1].Value
		if ($extractedVak -match "^[a-zA-Z]{8,10}$") {
			$extractedVak = ""
		}

		if ($extractedVak -eq "") {
			continue
		}
		else {
			$extractedVak = $extractedVak.Substring(0, 1).ToUpper() + $extractedVak.Substring(1)
		}
		
		if (-not $Vakken.Contains($extractedVak)) {
			$Vakken += $extractedVak
		}
		
		$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
		if ($event.ContainsKey("TZID")) {
			$timeZone = $event["TZID"]
			$timeZoneInfo = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZone)
			$startDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($startDate, $timeZone)
		}

		$lessonSlot = @{}
		for ($i = 0; $i -lt $lessonTimes.Count - 1; $i++) {
			$startTime = [datetime]::ParseExact($lessonTimes[$i], "HH:mm", $null)
			$endTime = [datetime]::ParseExact($lessonTimes[$i + 1], "HH:mm", $null)
			if ($startDate.TimeOfDay -ge $startTime.TimeOfDay -and $startDate.TimeOfDay -lt $endTime.TimeOfDay) {
				$lessonSlot[$i] = ($i + 1)
				break
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

		$dayCode = $startDate.ToString("ddd").ToUpperInvariant().Substring(0, 2)

		$dayCodeMap = @{
			"MA" = "MO"
			"DI" = "TU"
			"WO" = "WE"
			"DO" = "TH"
			"VR" = "FR"
		}

		if ($dayCodeMap.ContainsKey($dayCode)) {
			$mappedDayCode = $dayCodeMap[$dayCode]
	
			if ($days.ContainsKey($mappedDayCode)) {
				if (-not $days[$mappedDayCode].Contains($extractedVak)) {
					$days[$mappedDayCode] += $extractedVak
				}
			}
		}
	}
	
	$Global:Maandag = $days["MO"]
	$Global:Dinsdag = $days["TU"]
	$Global:Woensdag = $days["WE"]
	$Global:Donderdag = $days["TH"]
	$Global:Vrijdag = $days["FR"]

	foreach ($vak in $VakTimes.Keys) {
		Set-Variable -Name $vak -Value $VakTimes[$vak] -Scope Global
	}

	$Vakken = $Vakken | Sort-Object
	return $Vakken
}
Function New-Table {
	Param (
		[hashtable]$Days
	)

	if (-not $Days) {
		Write-Host "Error #3" -ForegroundColor Red
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
		foreach ($day in @("MO", "TU", "WE", "TH", "FR")) {
			if ($Days.ContainsKey($day) -and $Days[$day].Count -ge $hour) {
				if ($($Days[$day][$hour - 1]).Length -eq 3) {
					$row += " $($Days[$day][$hour - 1])  ｜"
				}
				elseif ($($Days[$day][$hour - 1]).Length -eq 4) {
					$row += " $($Days[$day][$hour - 1]) ｜"
				}
				else {
					$row += "  $($Days[$day][$hour - 1])  ｜"
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
	Test-Path "HKCU:\Software\rooster" | Out-Null || Write-Host "Error #3`nVoer eerst `"rooster --register`"uit`n" -ForegroundColor Red && $icsUrl (Get-ItemProperty -Path "HKCU:\Software\rooster" -Name "icsUrl").icsUrl
}
elseif ($isLinux) {
	Test-Path "~/.config/rooster/icsUrl" | Out-Null || Write-Host "Error #3`nVoer eerst `"rooster --register`"uit`n" -ForegroundColor Red && $icsUrl = (Get-Content -Path ~/.config/rooster/icsUrl)
}

$Vakken = Import-ICS -Url $icsUrl

$Days = @{
	"MO" = $Maandag
	"TU" = $Dinsdag
	"WE" = $Woensdag
	"TH" = $Donderdag
	"FR" = $Vrijdag
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
					Write-Host $HourValue -ForegroundColor Red
				}
				else {
					Write-Host $HourValue
				}
			}
			else {
				Write-Host "Error #2" -ForegroundColor Red
			}
		}
		else {
			Write-Host "Error #3" -ForegroundColor Red
		}
	}
	else {
		Write-Host "Error #2" -ForegroundColor Red
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
			New-Item -Path ~/.config/rooster -Name "icsUrl" -ItemType "File" -Value $Args[1]
		}
	}
	else {
		Write-Host 'Ga naar Somtoday. Open de instellingen. Ga naar "Agenda" en kopieer de link nadat je op "Aan de slag" hebt geklikt.'
		Write-Host '(Als je geen Somtoday gebruikt maar een andere ELO moet je daarin een iCalender link zien te vinden.)'
		$URLInput = Read-Host "Plak hier de link"
		if ($URLInput -notmatch "(https://.+)|(http://.+)") {
			Write-Host "Voer hier alleen een link in." -ForegroundColor Red
		}
		elseif ($URLInput -eq "") {
			Write-Host "Plak hier a.u.b. de link in." -ForegroundColor Red
		}
		else {
			if ($isWindows) {
				New-Item -ItemType Directory -Path HKCU:\Software\rooster -Force
				New-ItemProperty -Path "HKCU:\Software\rooster" -Name "icsUrl" -Value $URLInput -PropertyType String -Force | Out-Null && Write-Host "Link succesvol geregistreerd." -ForegroundColor Green || Write-Host "Er is een fout opgetreden bij het registreren van de link." -ForegroundColor Red
			}
			elseif ($isLinux) {
				New-Item -ItemType Directory -Path ~/.config/rooster -Force
				New-Item -Path "~/.config/rooster" -Name "icsUrl" -ItemType File -Value $URLInput -Force | Out-Null && Write-Host "Link succesvol geregistreerd." -ForegroundColor Green || Write-Host "Er is een fout opgetreden bij het registreren van de link." -ForegroundColor Red
			}
		}
	}
}
else {
	Write-Host "Error #2" -Foregroundcolor Red
	Write-Host 'Probeer "./rooster --help" in je terminal (waarschijnlijk cmd) uit te voeren.'
	Write-Host ""
	if ($isWindows) {
		cmd /c pause
	}
	elseif ($isLinux) {
		echo "Press any key to continue..."; bash -c "read -n1"
	}
	exit 2
}
