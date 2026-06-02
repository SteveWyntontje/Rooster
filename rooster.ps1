Param (
	[CmdletBinding()]
	[switch]$Tabel,
	[switch]$Registreer,
	[switch]$Help
)

Function Import-ICS {
	Param (
		[CmdletBinding()]
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

	foreach ($event in $events) {
		if (-not $event.ContainsKey("SUMMARY") -or -not $event.ContainsKey("DTSTART") -or -not $event.ContainsKey("DTEND")) {
			continue
		}
		$summary = $event["SUMMARY"]
		$match = [regex]::Match($summary, '(?<lokaal>[a-z0-9]{1,4}) - (?<klas>[a-z0-9]{1,2}?)(?<vak>[a-zA-Z]{2,8})')
		$extractedLokaal = $match.Groups['lokaal'].Value
		$extractedKlas = $match.Groups['klas'].Value
		$extractedVak = $match.Groups['vak'].Value

		$startDate = [DateTime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
		$startTime = $startDate.TimeOfDay
		$endDate = [DateTime]::ParseExact($event["DTEND"], "yyyyMMddTHHmmssZ", $null)
		$endTime = $endDate.TimeOfDay

		$dayCode = $startDate.ToString("ddd", [System.Globalization.CultureInfo]::GetCultureInfo("nl-NL")).ToUpperInvariant().Substring(0, 2)

		if ($days.ContainsKey($dayCode)) {
			if (-not $days[$dayCode].Contains($extractedVak)) {
				$days[$dayCode] += $extractedVak
			}
		}
	}

	$script:Maandag = $days["Ma"]
	$script:Dinsdag = $days["Di"]
	$script:Woensdag = $days["Wo"]
	$script:Donderdag = $days["Do"]
	$script:Vrijdag = $days["Vr"]

	Write-Verbose $days

	return
}
Function New-Table {
	Param (
		[CmdletBinding()]
		[hashtable]$Days
	)

	if (-not $Days) {
		Write-Error "Error #3"
		return @()
	}

	$table = @()

	$dayrow = "  Dag	┃   Ma   │   Di   │   Wo   │   Do   │   Vr   │"
	$seprow1 = "━━━━━━━━╋━━━━━━━━┿━━━━━━━━┿━━━━━━━━┿━━━━━━━━┿━━━━━━━━┥"
	$seprow2 = "────────╂────────┼────────┼────────┼────────┼────────┤"

	$table += $dayrow
	$table += $seprow1

	for ($hour = 1; $hour -le 9; $hour++) {
		$row = "   $hour" + "e   ┃"
		foreach ($day in @("Ma", "Di", "Wo", "Do", "Vr")) {
			if ($Days.ContainsKey($day) -and $Days[$day].Count -ge $hour) {
				if ($($Days[$day][$hour - 1]).Length -eq 3) {
					$row += "  $($Days[$day][$hour - 1])   │"
				}
				elseif ($($Days[$day][$hour - 1]).Length -eq 4) {
					$row += "  $($Days[$day][$hour - 1])  │"
				}
				else {
					$row += "  $($Days[$day][$hour - 1]) │"
				}
			}
			else {
				$row += "        │"
			}
		}
		$table += $row
		if ($hour -le 9) {
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

Import-ICS -Url $icsUrl

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

if ($Help) {
	write-host "rooster [-Dag <dag> [-Uur <uur>]] [-Tabel] [-Zoek <vak>] [-Registreer [<URL>]] [-Help]"
	write-host '-Tabel			Geeft het rooster weer.'
	write-host '-Zoek			Zoekt wanneer een vak is.'
	write-host '-Dag			De dag. Als je geen uur opgeeft, worden alle uren van die dag weergegeven.'
	write-host '-Uur			Het uur.'
	write-host '-Registreer		Registreert jouw Somtoday.'
	write-host '-Help			Toont deze helptekst.'
	write-host 'Dagen: Ma, Di, Wo, Do, Vr.'
	write-host 'Vakken: Is afhankelijk van wat je zelf hebt. '
	write-host 'Error #1 betekent "Geen Les Hier".'
	write-host 'Error #2 betekent "Verkeerde argumenten".'
	write-host 'Error #3 betekent "Algemene Fout".'
}
elseif ($Tabel) {
	for ($i = 0; $i -lt 19; $i++) {
		write-host $row[$i]
	}
	write-host ""
}
elseif ($Registreer) {
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
