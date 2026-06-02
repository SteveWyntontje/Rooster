# Rooster

## Installatie

1. Download [rooster.psm1](https://github.com/SteveWyntontje/Rooster/releases/download/v2.x/rooster.psm1).
2. Kopieer rooster.psm1 naar je CurrentUser modules pad (zie [hier](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath?view=powershell-7.6#long-description)).
3. Plak ```if ($isLinux) {Import-Module $HOME/.local/share/powershell/Modules/rooster.psm1} elseif ($isWindows) {Import-Module $HOME\Documents\PowerShell\Modules\rooster.psm1}``` in ```$profile```.
4. Voer ```rooster``` uit.

## Hoe het werkt

### Registreren

1. Ga naar Somtoday (of iets anders dat er op lijkt (ELO)).
2. Ga naar de instellingen.
3. Open het kopje "Agenda".
4. Klik op "Aan de slag".
5. Kopieer de link die bovenaan verschijnt.
6. Voer "rooster -Register" uit en plak dat linkje daarin.
7. Nu heb je je rooster geregistreerd!

[Hier](https://onzetaal.nl/taalloket/afkortingen-dagen-en-maanden#:~:text=van%20de%20dag-,afkorting%20in%20twee%20letters,-afkorting%20in%20twee)

### Help

Voer "rooster -Help" uit en je krijgt hulp.
