# Function to fetch and parse .ics file
Function Import-ICS {
    Param (
        [string]$Url
    )

    # Fetch the .ics file from the URL
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
        $icsContent = $response.Content
    } catch {
        Write-Host "Failed to fetch the .ics file." -ForegroundColor Red
        return
    }

    # Parse the .ics content
    $events = @()
    $currentEvent = @{}
    foreach ($line in $icsContent -split "`n") {
        $line = $line.Trim()
        if ($line -eq "BEGIN:VEVENT") {
            $currentEvent = @{}
        } elseif ($line -eq "END:VEVENT") {
            $events += $currentEvent
        } elseif ($line -match "^(?<key>[^:;]+):(?<value>.+)$") {
            $key = $matches['key']
            $value = $matches['value']
            $currentEvent[$key] = $value
        }
    }

    # Map events to days
    $days = @{
        "MO" = @()
        "TU" = @()
        "WE" = @()
        "TH" = @()
        "FR" = @()
    }

    foreach ($event in $events) {
        if ($event.ContainsKey("SUMMARY") -and $event.ContainsKey("DTSTART")) {
            $summary = $event["SUMMARY"]
            $startDate = [datetime]::ParseExact($event["DTSTART"], "yyyyMMddTHHmmssZ", $null)
            $dayCode = $startDate.ToString("ddd").ToUpperInvariant().Substring(0, 2)
            if ($days.ContainsKey($dayCode)) {
                $days[$dayCode] += $summary
            }
        }
    }

    # Update variables
    $script:Maandag = $days["MO"]
    $script:Dinsdag = $days["TU"]
    $script:Woensdag = $days["WE"]
    $script:Donderdag = $days["TH"]
    $script:Vrijdag = $days["FR"]
}

# Example usage
$icsUrl = "https://api.somtoday.nl/rest/v1/icalendar/stream/0792a6e2-9833-45e8-b1eb-1498cf22f10d/f894cd42-c5f0-452d-8c30-06d82eba86a2"
Import-ICS -Url $icsUrl

# Existing code continues...

$dayrow = "  Dag	| Ma   ｜  Di  ｜  Wo  ｜  Do  ｜  Vr  ｜"
$seprow1 = "════════|═══════════════════════════════════════"
$seprow2 = "⎯⎯⎯⎯⎯⎯⎯⎯|⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
$row = @("   1e	|  Wi  ｜ Gfs  ｜ Env  ｜      ｜  Dr  ｜"
	"   2e	| Gtc  ｜ Gfs  ｜  Lo  ｜  Du  ｜  Fa  ｜"
	"   3e	| Ltc  ｜ Gfs  ｜  Lo  ｜ Nask ｜ Nask ｜"
	"   4e	|  Bi  ｜  Ak  ｜  Ne  ｜  Wi  ｜ Ltc  ｜"
	"   5e	|  Ne  ｜  Fi  ｜  Gs  ｜  Gs  ｜  Wi  ｜"
	"   6e	|  Fi  ｜  Bi  ｜ Gtc  ｜  Ak  ｜  Te  ｜"
	"   7e	| Env  ｜  Tu  ｜  Te  ｜  Fa  ｜      ｜"
	"   8e	|      ｜      ｜  Du  ｜      ｜      ｜"
	"   9e	|      ｜      ｜      ｜      ｜      ｜"
)


$Vakken = "Ak", "Bi", "Dr", "Du", "Env", "Fi", "Fa", "Gfs", "Gs", "Gtc", "Lo", "Ltc", "Nask", "Ne", "Te", "Tu", "Wi"

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
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Ma") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		IF ($Maandag[0] -eq "Error #1") {
			write-host $Maandag[0] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[0]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		IF ($Maandag[1] -eq "Error #1") {
			write-host $Maandag[1] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[1]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		IF ($Maandag[3] -eq "Error #1") {
			write-host $Maandag[2] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[2]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		IF ($Maandag[4] -eq "Error #1") {
			write-host $Maandag[3] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[3]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		IF ($Maandag[4] -eq "Error #1") {
			write-host $Maandag[4] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[4]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		IF ($Maandag[5] -eq "Error #1") {
			write-host $Maandag[5] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[5]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		IF ($Maandag[6] -eq "Error #1") {
			write-host $Maandag[6] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[6]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		IF ($Maandag[7] -eq "Error #1") {
			write-host $Maandag[7] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[7]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		IF ($Maandag[8] -eq "Error #1") {
			write-host $Maandag[8] -foregroundcolor red
		}
		ELSE {
			write-host $Maandag[8]
		}
	}
	ELSEIF ($Args.count -eq 2) {
	[int]$MaCounter = 1
	while ($MaCounter -le 9) {
		write-host $MaCounter'e: ' -nonewline
		write-host $Maandag[($MaCounter-1)]
		$MaCounter++
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Di") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		IF ($Dinsdag[0] -eq "Error #1") {
			write-host $Dinsdag[0] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[0]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		IF ($Dinsdag[1] -eq "Error #1") {
			write-host $Dinsdag[1] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[1]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		IF ($Dinsdag[2] -eq "Error #1") {
			write-host $Dinsdag[2] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[2]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		IF ($Dinsdag[3] -eq "Error #1") {
			write-host $Dinsdag[3] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[3]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		IF ($Dinsdag[4] -eq "Error #1") {
			write-host $Dinsdag[4] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[4]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		IF ($Dinsdag[5] -eq "Error #1") {
			write-host $Dinsdag[5] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[5]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		IF ($Dinsdag[6] -eq "Error #1") {
			write-host $Dinsdag[6] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[6]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		IF ($Dinsdag[7] -eq "Error #1") {
			write-host $Dinsdag[7] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[7]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		IF ($Dinsdag[8] -eq "Error #1") {
			write-host $Dinsdag[8] -foregroundcolor red
		}
		ELSE {
			write-host $Dinsdag[8]
		}
	}
	ELSEIF ($Args.count -eq 2) {
	[int]$DiCounter = 1
	while ($DiCounter -le 9) {
		write-host $DiCounter'e: ' -nonewline
		write-host $Dinsdag[($DiCounter-1)]
		$DiCounter++
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Wo") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		IF ($Woensdag[0] -eq "Error #1") {
			write-host $Woensdag[0] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[0]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		IF ($Woensdag[1] -eq "Error #1") {
			write-host $Woensdag[1] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[1]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		IF ($Woensdag[2] -eq "Error #1") {
			write-host $Woensdag[2] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[2]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		IF ($Woensdag[3] -eq "Error #1") {
			write-host $Woensdag[3] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[3]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		IF ($Woensdag[4] -eq "Error #1") {
			write-host $Woensdag[4] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[4]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		IF ($Woensdag[5] -eq "Error #1") {
			write-host $Woensdag[5] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[5]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		IF ($Woensdag[6] -eq "Error #1") {
			write-host $Woensdag[6] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[6]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		IF ($Woensdag[7] -eq "Error #1") {
			write-host $Woensdag[7] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[7]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		IF ($Woensdag[8] -eq "Error #1") {
			write-host $Woensdag[8] -foregroundcolor red
		}
		ELSE {
			write-host $Woensdag[8]
		}
	}
	ELSEIF ($Args.count -eq 2) {
	[int]$WoCounter = 1
	while ($WoCounter -le 9) {
		write-host $WoCounter'e: ' -nonewline
		write-host $Woensdag[($WoCounter-1)]
		$WoCounter++
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Do") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		IF ($Donderdag[0] -eq "Error #1") {
			write-host $Donderdag[0] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[0]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		IF ($Donderdag[1] -eq "Error #1") {
			write-host $Donderdag[1] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[1]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		IF ($Donderdag[2] -eq "Error #1") {
			write-host $Donderdag[2] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[2]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		IF ($Donderdag[3] -eq "Error #1") {
			write-host $Donderdag[3] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[3]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		IF ($Donderdag[4] -eq "Error #1") {
			write-host $Donderdag[4] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[4]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		IF ($Donderdag[5] -eq "Error #1") {
			write-host $Donderdag[5] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[5]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		IF ($Donderdag[6] -eq "Error #1") {
			write-host $Donderdag[6] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[6]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		IF ($Donderdag[7] -eq "Error #1") {
			write-host $Donderdag[7] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[7]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		IF ($Donderdag[8] -eq "Error #1") {
			write-host $Donderdag[8] -foregroundcolor red
		}
		ELSE {
			write-host $Donderdag[8]
		}
	}
	ELSEIF ($Args.count -eq 2) {
	[int]$DoCounter = 1
	while ($DoCounter -le 9) {
		write-host $DoCounter'e: ' -nonewline
		write-host $Donderdag[($DoCounter-1)]
		$DoCounter++
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Vr") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		IF ($Vrijdag[0] -eq "Error #1") {
			write-host $Vrijdag[0] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[0]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		IF ($Vrijdag[1] -eq "Error #1") {
			write-host $Vrijdag[1] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[1]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		IF ($Vrijdag[2] -eq "Error #1") {
			write-host $Vrijdag[2] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[2]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		IF ($Vrijdag[3] -eq "Error #1") {
			write-host $Vrijdag[3] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[3]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		IF ($Vrijdag[4] -eq "Error #1") {
			write-host $Vrijdag[4] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[4]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		IF ($Vrijdag[5] -eq "Error #1") {
			write-host $Vrijdag[5] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[5]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		IF ($Vrijdag[6] -eq "Error #1") {
			write-host $Vrijdag[6] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[6]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		IF ($Vrijdag[7] -eq "Error #1") {
			write-host $Vrijdag[7] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[7]
		}
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		IF ($Vrijdag[8] -eq "Error #1") {
			write-host $Vrijdag[8] -foregroundcolor red
		}
		ELSE {
			write-host $Vrijdag[8]
		}
	}
	ELSEIF ($Args.count -eq 2) {
	[int]$VrCounter = 1
	while ($VrCounter -le 9) {
		write-host $VrCounter'e: ' -nonewline
		write-host $Vrijdag[($VrCounter-1)]
		$VrCounter++
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
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
		while ($SearchCounter -lt $($Args[1]).length) {
			IF ($Args[1] -eq "Ak") {
				write-host $Ak[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Bi") {
				write-host $Bi[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Dr") {
				write-host $Dr[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Du") {
				write-host $Du[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Env") {
				write-host $Env[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Fi") {
				write-host $Fi[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Fa") {
				write-host $Fa[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Gfs") {
				write-host $Gfs[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Gs") {
				write-host $Gs[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Gtc") {
				write-host $Gtc[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Lo") {
				write-host $Lo[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Ltc") {
				write-host $Ltc[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Nask") {
				write-host $Nask[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Ne") {
				write-host $Ne[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Te") {
				write-host $Te[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Tu") {
				write-host $Tu[$SearchCounter]
				$SearchCounter++
			}
			ELSEIF ($Args[1] -eq "Wi") {
				write-host $Wi[$SearchCounter]
				$SearchCounter++
			}
		}
	}
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-r" -Or $Args[0] -eq "--Rooster") {
	write-host $dayrow
	write-host $seprow1
	FOR ($i = 0; $i -lt 9; $i++) {
		write-host $row[$i]
		IF ($i -lt 8) {
			write-host $seprow2
		}
	}
}
ELSE {
	write-host "Error #2" -Foregroundcolor Red
	write-host 'Probeer "Rooster --help" in cmd uit te voeren.'
	write-host `n -NoNewline
	Pause
}