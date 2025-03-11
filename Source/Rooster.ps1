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

$Maandag = "Wi", "Gtc", "Ltc", "Bi", "Ne", "Fi", "Env", "", ""
$Dinsdag = "Gfs", "Gfs", "Gfs", "Ak", "Fi", "Bi", "Tu", "", ""
$Woensdag = "Env", "Lo", "Lo", "Ne", "Gs", "Gtc", "Te", "Du", ""
$Donderdag = "", "Du", "Nask", "Wi", "Gs", "Ak", "Fa", "", ""
$Vrijdag = "Dr", "Fa", "Nask", "Ltc", "Wi", "Te", "", "", ""

$Vakken = "Ak", "Bi", "Dr", "Du", "Env", "Fi", "Fa", "Gfs", "Gs", "Gtc", "Lo", "Ltc", "Nask", "Ne", "Tu", "Wi"

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
$Tu = "Di: 7e"
$Wi = "Ma: 1e", "Do: 4e", "Vr: 5e"

IF ($Args[0] -eq "--help" -Or $Args[0] -eq "-h") {
	write-host "ROOSTER [-d Dag [-u Uur]] [-r] [-s Vak]"
	write-host '-r, --Rooster     Geeft het rooster weer.'
	write-host '-s, --Search	Zoekt wanneer een vak is.'
	write-host '-d	    De dag. Als je geen uur opgeeft, worden alle uren van die dag weergegeven.'
	write-host '-u	    Het uur.'
	write-host 'Dagen: Ma, Di, Wo, Do, Vr.'
	write-host 'Vakken: Ak, Bi, Dr, Du, Env, Fi, Fa, Gfs, Gs, Gtc, Lo, Ltc, Nask, Ne, Tu, Wi.'
	write-host 'Error #1 betekent "Geen Les Hier".'
	write-host 'Error #2 betekent "Verkeerde argumenten".'
}
ELSEIF ($Args[0] -eq "-d" -And $Args[1] -eq "Ma") {
	IF ($Args[2] -eq "-u" -And $Args[3] -eq "1") {
		write-host $Maandag[0]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		write-host $Maandag[1]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		write-host $Maandag[2]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		write-host $Maandag[3]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		write-host $Maandag[4]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		write-host $Maandag[5]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		write-host $Maandag[6]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		write-host $Maandag[7]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		write-host "Error #1" -ForegroundColor Red
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
		write-host $Dinsdag[0]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		write-host $Dinsdag[1]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		write-host $Dinsdag[2]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		write-host $Dinsdag[3]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		write-host $Dinsdag[4]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		write-host $Dinsdag[5]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		write-host $Dinsdag[6]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		write-host "Error #1" -ForegroundColor Red
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
		write-host $Woensdag[0]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		write-host $Woensdag[1]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		write-host $Woensdag[2]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		write-host $Woensdag[3]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		write-host $Woensdag[4]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		write-host $Woensdag[5]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		write-host $Woensdag[6]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		write-host "Error #1" -ForegroundColor Red
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
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		write-host $Donderdag[1]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		write-host $Donderdag[2]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		write-host $Donderdag[3]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		write-host $Donderdag[4]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		write-host $Donderdag[5]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		write-host $Donderdag[6]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		write-host $Donderdag[7]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		write-host "Error #1" -ForegroundColor Red
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
		write-host $Vrijdag[0]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "2") {
		write-host $Vrijdag[1]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "3") {
		write-host $Vrijdag[2]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "4") {
		write-host $Vrijdag[3]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "5") {
		write-host $Vrijdag[4]
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "6") {
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "7") {
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "8") {
		write-host "Error #1" -ForegroundColor Red
	}
	ELSEIF ($Args[2] -eq "-u" -And $Args[3] -eq "9") {
		write-host "Error #1" -ForegroundColor Red
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
		while ($SearchCounter -le $($Args[1]).length) {
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
	write-host $row[0]
	write-host $seprow2
	write-host $row[1]
	write-host $seprow2
	write-host $row[2]
	write-host $seprow2
	write-host $row[3]
	write-host $seprow2
	write-host $row[4]
	write-host $seprow2
	write-host $row[5]
	write-host $seprow2
	write-host $row[6]
	write-host $seprow2
	write-host $row[7]
	write-host $seprow2
	write-host $row[8]
	write-host $seprow2
}
ELSE {
	write-host "Error #2" -Foregroundcolor Red
	write-host 'Probeer "Rooster --help" in cmd uit te voeren.'
	write-host `n -NoNewline
	Pause
}