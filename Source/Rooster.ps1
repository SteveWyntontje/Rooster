$dayrow = "  Dag	｜ Ma   |  Di  |  Wo  |  Do  |  Vr  |"
$seprow1 = "════════｜══════════════════════════════════"
$seprow2 = "⎯⎯⎯⎯⎯⎯⎯⎯｜⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
$row = @("   1e	｜  Wi  | Gfs  | Env  |      |  Dr  |"
	"   2e	｜ Gtc  | Gfs  |  Lo  |  Du  |  Fa  |"
	"   3e	｜ Ltc  | Gfs  |  Lo  | Nask | Nask |"
	"   4e	｜  Bi  |  Ak  |  Ne  |  Wi  | Ltc  |"
	"   5e	｜  Ne  |  Fi  |  Gs  |  Gs  |  Wi  |"
	"   6e	｜  Fi  |  Bi  | Gtc  |  Ak  |  Te  |"
	"   7e	｜ Env  |  Tu  |  Te  |  Fa  |      |"
	"   8e	｜      |      |  Du  |      |      |"
	"   9e	｜      |      |      |      |      |"
)

$Maandag = "Wi", "Gtc", "Ltc", "Bi", "Ne", "Fi", "Env", "", ""
$Dinsdag = "Gfs", "Gfs", "Gfs", "Ak", "Fi", "Bi", "Tu", "", ""
$Woensdag = "Env", "Lo", "Lo", "Ne", "Gs", "Gtc", "Te", "Du", ""
$Donderdag = "", "Du", "Nask", "Wi", "Gs", "Ak", "Fa", "", ""
$Vrijdag = "Dr", "Fa", "Nask", "Ltc", "Wi", "Te", "", "", ""

$Vakken="Ak", "Bi", "Dr", "Du", "Env", "Fi", "Fa", "Gfs", "Gs", "Gtc", "Lo", "Ltc", "Nask", "Ne", "Tu", "Wi"

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
	write-host "ROOSTER [-d Dag -u Uur] [-r] [-s Vak]"
	write-host '-r, --Rooster	Geeft het rooster weer.'
	write-host '-s, --Search	Zoekt wanneer een vak is.'
	write-host '-d		De dag.'
	write-host '-u		Het uur.'
	write-host 'De mogelijke vakken zijn: Ak, Bi, Dr, Du, Env, Fi, Fa, Gfs, Gs, Gtc, Lo, Ltc, Nask, Ne, Tu, Wi.'
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
	ELSE {
		write-host "Error #2" -ForegroundColor Red
	}
}
ELSEIF ($Args[0] -eq "-s" -Or $Args[0] -eq "--Search") {
	[int]$i = 0
	while ($i -le $($Args[1]).length) {
		IF ($Args[1] -eq "Ak") {
			write-host $Ak[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Bi") {
			write-host $Bi[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Dr") {
			write-host $Dr[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Du") {
			write-host $Du[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Env") {
			write-host $Env[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Fi") {
			write-host $Fi[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Fa") {
			write-host $Fa[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Gfs") {
			write-host $Gfs[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Gs") {
			write-host $Gs[$1]
			$i++
		}
		ELSEIF ($Args[1] -eq "Gtc") {
			write-host $Gtc[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Lo") {
			write-host $Lo[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Ltc") {
			write-host $Ltc[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Nask") {
			write-host $Nask[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Ne") {
			write-host $Ne[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Tu") {
			write-host $Tu[$i]
			$i++
		}
		ELSEIF ($Args[1] -eq "Wi") {
			write-host $Wi[$i]
			$i++
		}
		ELSE {
			write-host "Error #2" -Foregroundcolor Red
		}
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
	IF ($true) {
		# show console environment
		switch ($Host.Name) {
			'ConsoleHost'					{Write-Host "Running from CLI"}
			'Windows PowerShell ISE Host'	{Write-Host "Running from GUI (Windows PowerShell ISE)"}
			'Visual Studio Code Host'		{Write-Host "Running from GUI (VS Code)"}
			'Explorer Host'					{Write-Host "Running from GUI (Explorer)"}
			default							{Write-Host "Running from GUI ($_)" }
		}
	}
	write-host "Error #2" -Foregroundcolor Red
	write-host 'Probeer "Rooster --help" in cmd uit te voeren.'
	write-host `n -NoNewline
	Pause
}
