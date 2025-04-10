Function Import-ICS {
	Param (
		[string]$Url
	)

	# Fetch the .ics file from the URL
	try {
		$response = Invoke-WebRequest -Uri $Url -UseBasicParsing
		$icsContent = $response.Content
	}
	catch {
		Write-Host "Failed to fetch the .ics file." -ForegroundColor Red
		return
	}

	# Parse the .ics content
	$events = @()
	$currentEvent = @{}
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
        "08:10", "09:00", "09:50", 					# Morning lessons
        "11:00", "11:50",							# After first break
        "13:10", "14:00", "14:50", "15:40", "16:30"	# After second break
    )

	# Map events to days
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
			continue
		}
	
		# Extract the desired part of the SUMMARY field
		$Lokaal = $event["SUMMARY"] -match "([a-z0-9]{1,4})" | Out-Null
		$extractedLokaal = $matches[0]
		$Klas = $event["SUMMARY"] -match "$extractedLokaal - ([a-z0-9]{2})" | Out-Null
		$extractedKlas = $matches[1]
		$Vak = $event["SUMMARY"] -match "$extractedKlas([a-zA-Z]{2,4})" | Out-Null
		$extractedVak = $matches[1]
	
		# Capitalize the first letter of the extracted summary
		$extractedVak = $extractedVak.Substring(0, 1).ToUpper() + $extractedVak.Substring(1)
		IF (-not $Vakken.Contains($extractedVak)) {
			$Vakken += $extractedVak
		}
		
		# Handle time zone (TZID) IF present
		IF ($event.ContainsKey("TZID")) {
			$timeZone = $event["TZID"]
			$timeZoneInfo = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZone)
			$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
			$startDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($startDate, $timeZone)
		}
		ELSE {
			$startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmss", $null)
		}
	
		# Determine the lesson slot
        $lessonSlot = @{}
        for ($i = 0; $i -lt $lessonTimes.Count - 1; $i++) {
            $startTime = [datetime]::ParseExact($lessonTimes[$i], "HH:mm", $null)
            $endTime = [datetime]::ParseExact($lessonTimes[$i + 1], "HH:mm", $null)
            if ($startDate.TimeOfDay -ge $startTime.TimeOfDay -and $startDate.TimeOfDay -lt $endTime.TimeOfDay) {
                $lessonSlot[$i] = ($i + 1) + "e" # e.g., "1e", "2e"
                break
            }
        }

        if (-not $lessonSlot) {
            continue # Skip events that don't fit into a lesson slot
        }

		# Get the Dutch day code
		$dayCode = $startDate.ToString("ddd").ToUpperInvariant().Substring(0, 2)
	
		# Map Dutch day codes to English day codes
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
				# Add the extracted summary only IF it doesn't already exist
				IF (-not $days[$mappedDayCode].Contains($extractedVak)) {
					$days[$mappedDayCode] += $extractedVak
				}
			}
		}
	}

	# Update variables
	$Global:Maandag = $days["MO"]
	$Global:Dinsdag = $days["TU"]
	$Global:Woensdag = $days["WE"]
	$Global:Donderdag = $days["TH"]
	$Global:Vrijdag = $days["FR"]

	$Vakken = $Vakken | Sort-Object
	return $Vakken
}
Function Generate-Table {
	Param (
		[hashtable]$Days
	)

	# Ensure $Days is valid
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

$icsUrl = "https://api.somtoday.nl/rest/v1/icalendar/stream/0792a6e2-9833-45e8-b1eb-1498cf22f10d/f894cd42-c5f0-452d-8c30-06d82eba86a2"

$Vakken = Import-ICS -Url $icsUrl

$Days = @{
	"MO" = $Maandag
	"TU" = $Dinsdag
	"WE" = $Woensdag
	"TH" = $Donderdag
	"FR" = $Vrijdag
}

$row = Generate-Table -Days $Days

$Dagen = @("Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag")
$DagCodes = @("Ma", "Di", "Wo", "Do", "Vr")
$DagMap = @{
	"Ma" = "Maandag"
	"Di" = "Dinsdag"
	"Wo" = "Woensdag"
	"Do" = "Donderdag"
	"Vr" = "Vrijdag"
}

$Ak = "Di: 4e", "Do: 6e"
$Bi = "Ma: 4e", "Di: 6e"
$Dr = "Vr: 1e"
$Du = "Wo: 8e", "Do: 2e"
$Env = "Ma: 7e", "Wo: 1e"
$Fi = "Ma: 6e", "Di: 5e"
$Fa = "Do: 7e", "Vr: 2e"
$Gfs = "Ma: 1e", "Ma: 2e", "Ma: 3e"
$Gs = "Wo: 5e", "Do: 5e"
$Gtc = "Ma: 2e", "Wo: 6e"
$Lo = "Wo: 2e", "Wo: 3e"
$Ltc = "Ma: 3e", "Vr: 4e"
$Nask = "Do: 3e", "Vr: 3e"
$Ne = "Ma: 5e", "Wo: 4e"
$Te = "Wo: 7e", "Vr: 6e"
$Tu = "Di: 7e"
$Wi = "Ma: 1e", "Do: 4e", "Vr: 5e"

IF ($Args[0] -eq "--help" -Or $Args[0] -eq "-h") {
	write-host "ROOSTER [-d Dag [-u Uur]] [-r] [-s Vak]"
	write-host '-r, --Rooster	Geeft het rooster weer.'
	write-host '-s, --Search	Zoekt wanneer een vak is.'
	write-host '-d  	De dag. Als je geen uur opgeeft, worden alle uren van die dag weergegeven.'
	write-host '-u  	Het uur.'
	write-host 'Dagen: Ma, Di, Wo, Do, Vr.'
	write-host 'Vakken: Ak, Bi, Dr, Du, Env, Fi, Fa, Gfs, Gs, Gtc, Lo, Ltc, Nask, Ne, Tu, Wi.'
	write-host 'Error #1 betekent "Geen Les Hier".'
	write-host 'Error #2 betekent "Verkeerde argumenten".'
	write-host 'Error #3 betekent "Algemene Fout".'
}
ELSEIF ($Args[0] -eq "-d") {
	IF ($DagMap.ContainsKey($Args[1])) {
		$SelectedDag = $DagMap[$Args[1]]
		FOREACH ($Dag in $Dagen) {
			IF ($Dag -eq $SelectedDag) {
				IF ($Args.count -eq 2) {
					FOR ($Counter = 1; $Counter -le 9; $Counter++) {
						Write-Host "$Counter"e: " -NoNewline
                        Write-Host $($Dag)[$Counter - 1]
                    }
				}
                ELSEIF ($Args[2] -eq "-u") {
					IF ($Args[3] -match "^[1-9]$") {
                    	$HourIndex = [int]$Args[3] - 1
                    	IF ($($Dag)[$HourIndex] -eq "Error #1") {
							Write-Host $($Dag)[$HourIndex] -ForegroundColor Red
						}
						ELSE {
							Write-Host $($Dag)[$HourIndex]
						}
					}
				}
				ELSE {
					Write-Host "Error #2" -ForegroundColor Red
				}
			}
		}
	}
}
ELSE {
	Write-Host "Error #2" -ForegroundColor Red
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
		WHILE ($SearchCounter -lt $($Args[1]).Length) {
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
ELSE {
	write-host "Error #2" -Foregroundcolor Red
	write-host 'Probeer "Rooster --help" in cmd uit te voeren.'
	write-host `n -NoNewline
	Pause
}