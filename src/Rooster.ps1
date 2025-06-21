Function Import-ICS {
	Param (
		[string]$Url
	)

	TRY {
		$response = Invoke-WebRequest -Uri $Url
		$icsContent = $response.Content
	}
	CATCH {
		Write-Host "Kon het .ics-bestand niet downloaden." -ForegroundColor Red
		RETURN
	}

	Write-Host $icsContent
	$events = @()
	$currentEvent = @{}
	$VakTimes = @{}
	FOREACH ($line in $icsContent -split "`n") {
		$line = $line.Trim()
		IF ($line -eq "BEGIN:VEVENT") {
			$currentEvent = @{}
		}
		ELSEIF ($line -eq "END:VEVENT") {
			$events += $currentEvent
		}
		ELSEIF ($line -match "^(?<key>[^:;]+)(;TZID=(?<tzid>[^:;]+))?:(?<value>.+)$") {
			$key = $matches['key']
			$value = $matches['value']
			IF ($matches['tzid']) {
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
	FOREACH ($event in $events) {
		IF (-not $event.ContainsKey("SUMMARY") -or -not $event.ContainsKey("DTSTART")) {
			CONTINUE
		}

		$Lokaal = $event["SUMMARY"] -match "([a-z0-9]{1,4})" | Out-Null
		$extractedLokaal = $matches[0]
		$Klas = $event["SUMMARY"] -match "$extractedLokaal - ([a-z0-9]{2})" | Out-Null
		$extractedKlas = $matches[1]
		$Vak = $event["SUMMARY"] -match "$extractedKlas([a-zA-Z]{2,8})" | Out-Null
		$extractedVak = $matches[1]
		IF ($extractedVak -match "^[a-zA-Z]{8,10}$") {
			$extractedVak = ""
		}

		IF ($extractedVak -eq "") {
			CONTINUE
		}
		ELSE {
			$extractedVak = $extractedVak.Substring(0, 1).ToUpper() + $extractedVak.Substring(1)
		}
		
		IF (-not $Vakken.Contains($extractedVak)) {
			$Vakken += $extractedVak
		}
		
		IF ($event.ContainsKey("TZID")) {
			$timeZone = $event["TZID"]
			$timeZoneInfo = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZone)
			$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
			$startDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($startDate, $timeZone)
		}
		ELSE {
			$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmss", $null)
		}

		$lessonSlot = @{}
		FOR ($i = 0; $i -lt $lessonTimes.Count - 1; $i++) {
			$startTime = [datetime]::ParseExact($lessonTimes[$i], "HH:mm", $null)
			$endTime = [datetime]::ParseExact($lessonTimes[$i + 1], "HH:mm", $null)
			IF ($startDate.TimeOfDay -ge $startTime.TimeOfDay -and $startDate.TimeOfDay -lt $endTime.TimeOfDay) {
				$lessonSlot[$i] = ($i + 1)
				BREAK
			}
		}

		IF (-not $lessonSlot) {
			CONTINUE
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
	
		IF ($dayCodeMap.ContainsKey($dayCode)) {
			$mappedDayCode = $dayCodeMap[$dayCode]
	
			IF ($days.ContainsKey($mappedDayCode)) {
				IF (-not $days[$mappedDayCode].Contains($extractedVak)) {
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

	IF (-not $Days) {
		Write-Host "Error #3" -ForegroundColor Red
		return @()
	}

	$table = @()

	$dayrow = "  Dag	|  Ma  ｜  Di  ｜  Wo  ｜  Do  ｜  Vr  ｜"
	$seprow1 = "════════|═══════════════════════════════════════"
	$seprow2 = "⎯⎯⎯⎯⎯⎯⎯⎯|⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"

	$table += $dayrow
	$table += $seprow1

	FOR ($hour = 1; $hour -le 9; $hour++) {
		$row = "   $hour" + "e   |"
		FOREACH ($day in @("MO", "TU", "WE", "TH", "FR")) {
			IF ($Days.ContainsKey($day) -and $Days[$day].Count -ge $hour) {
				IF ($($Days[$day][$hour - 1]).Length -eq 3) {
					$row += " $($Days[$day][$hour - 1])  ｜"
				}
				ELSEIF ($($Days[$day][$hour - 1]).Length -eq 4) {
					$row += " $($Days[$day][$hour - 1]) ｜"
				}
				ELSE {
					$row += "  $($Days[$day][$hour - 1])  ｜"
				}
			}
			ELSE {
				$row += "      ｜"
			}
		}
		$table += $row
		IF ($hour -lt 9) {
			$table += $seprow2
		}
	}
	return $table
}

Try {
	Test-Path "HKCU:\Software\Rooster"
	$icsUrl = (Get-ItemProperty -Path "HKCU:\Software\Rooster" -Name "icsUrl").icsUrl
}
Catch {
	Write-Host "Error #3" -ForegroundColor Red
	Write-Host 'Voer eerst "Rooster --register" uit.' -ForegroundColor Red
	Write-Host "`n"
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

IF ($Args[0] -eq "--help" -Or $Args[0] -eq "-h") {
	write-host "ROOSTER [-d Dag [-u Uur]] [-r] [-s Vak] [--Register [URL]] [-h]"
	write-host '-r, --Rooster	Geeft het rooster weer.'
	write-host '-s, --Search	Zoekt wanneer een vak is.'
	write-host '-d		De dag. Als je geen uur opgeeft, worden alle uren van die dag weergegeven.'
	write-host '-u		Het uur.'
	write-host '--Register		Registreert jouw Somtoday.'
	write-host '-h, --help		Toont deze helptekst.'
	write-host 'Dagen: Ma, Di, Wo, Do, Vr.'
	write-host 'Vakken: Ak, Bi, Dr, Du, Env, Fi, Fa, Gfs, Gs, Gtc, Lo, Ltc, Nask, Ne, Tu, Wi.'
	write-host 'Error #1 betekent "Geen Les Hier".'
	write-host 'Error #2 betekent "Verkeerde argumenten".'
	write-host 'Error #3 betekent "Algemene Fout".'
}
ELSEIF ($Args[0] -eq "-d") {
	IF ($DagMap.ContainsKey($Args[1])) {
		$SelectedDag = $DagMap[$Args[1]]
		IF ($Dagen -contains $SelectedDag) {
			IF ($Args.Count -eq 2) {
				$DayArray = Get-Variable -Name $SelectedDag -ValueOnly
				FOR ($Counter = 1; $Counter -le 9; $Counter++) {
					Write-Host $Counter"e: " -NoNewline
					Write-Host $DayArray[$Counter - 1]
				}
			}
			ELSEIF ($Args.Count -eq 4 -and $Args[2] -eq "-u" -and $Args[3] -match "^[1-9]$") {
				$DayArray = Get-Variable -Name $SelectedDag -ValueOnly
				$HourIndex = [int]$Args[3] - 1
				$HourValue = $DayArray[$HourIndex]
				IF ($HourValue -eq "Error #1") {
					Write-Host $HourValue -ForegroundColor Red
				}
				ELSE {
					Write-Host $HourValue
				}
			}
			ELSE {
				Write-Host "Error #2" -ForegroundColor Red
			}
		}
		ELSE {
			Write-Host "Error #3" -ForegroundColor Red
		}
	}
	ELSE {
		Write-Host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-s" -Or $Args[0] -eq "--Search") {
	[int]$NietVakCount = 0
	[int]$WelVakCount = 0
	[int]$VakkenCounter = 0
	WHILE ($VakkenCounter -le $Vakken.count) {
		IF ($Args[1] -ne $Vakken[$VakkenCounter]) {
			$NietVakCount++
		}
		ELSE {
			$WelVakCount++
		}
		$VakkenCounter++
	}
	IF ($WelVakCount -eq 1) {
		[int]$SearchCounter = 0
		WHILE ($SearchCounter -le $($Args[1]).Length) {
			FOREACH ($Vak in $Vakken) {
				IF ($Args[1] -eq $Vak) {
					write-host $(Get-Variable -Name $Args[1] -ValueOnly)[$SearchCounter]
					$SearchCounter++
				}
			}
		}
	}
}
ELSEIF ($Args[0] -eq "-r" -Or $Args[0] -eq "--Rooster") {
	FOR ($i = 0; $i -lt 19; $i++) {
		write-host $row[$i]
	}
	write-host `n -NoNewline
}
ELSEIF ($Args[0] -eq "--Register") {
	IF (($Args.Count -eq 2) -and ($Args[1] -match "https://api\.somtoday.nl/rest/v1/icalendar/stream/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}")) {
		New-ItemProperty -Path "HKCU:\Software\Rooster" -Name "icsUrl" -Value $Args[1] -PropertyType String -Force | Out-Null
	}
	ELSE {
		Write-Host 'Ga naar Somtoday. Open de instellingen. Ga naar "Agenda" en kopieer de link nadat je op "Aan de slag" hebt geklikt.'
		$URLInput = Read-Host "Plak hier de link"
		IF ($URLInput -notmatch "https://api\.somtoday.nl/rest/v1/icalendar/stream/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}") {
			Write-Host "Voer hier alleen een link in." -ForegroundColor Red
		}
		ELSEIF ($URLInput -eq "") {
			Write-Host "Voer hier alsjeblieft een link in." -ForegroundColor Red
		}
		ELSE {
			Try {
			New-ItemProperty -Path "HKCU:\Software\Rooster" -Name "icsUrl" -Value $URLInput -PropertyType String -Force | Out-Null
			Write-Host "Link succesvol geregistreerd." -ForegroundColor Green
			}
			Catch {
				Write-Host "Er is een fout opgetreden bij het registreren van de link." -ForegroundColor Red
			}
		}
	}
}
ELSE {
	Write-Host "Error #2" -Foregroundcolor Red
	Write-Host 'Probeer "Rooster --help" in cmd uit te voeren.'
	Write-Host ""
	cmd /c pause
	exit 2
}