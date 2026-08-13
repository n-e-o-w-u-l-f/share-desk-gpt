# share-desk-gpt

Plattformsoberoende installations- och CLI-bas för **share-desk-gpt**.

> **Aktuell status:** det offentliga repositoriet innehåller ännu ingen riktig startpunkt för applikationen. Den här versionen bygger därför bara installations- och runtime-lagret utan att hitta på funktioner.

## Funktion

Installationsprogrammet hittar `PATH`, kontrollerar Node.js/npm/npx, installerar Node.js endast vid behov, verifierar SHA-256 och skapar kommandot `share-desk-gpt` i användarens PATH.

`npx` installeras inte separat utan ingår i npm via `npx`/`npm exec`.

NixOS använder Nix i stället för att skriva till `/usr/bin`. SteamOS använder en lokal användarinstallation för att skydda det immutabla bassystemet.

## Installation

Linux:

```bash
bash scripts/install.sh
```

Systemomfattande:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Kontrollera:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Plattformar

Windows x64/ARM64 och Linux x64/ARM64/ARMv7. ARMv7 använder Node.js 22 eftersom Node.js 24 inte längre publicerar en aktuell Linux ARMv7-build.

Arch Linux, Debian, Ubuntu och Raspberry Pi OS använder lokal runtime när Node/npm saknas. NixOS använder Nix. SteamOS behåller installationen på användarnivå.

## Stabilitet

Användarinstallation är standard: inget root/admin krävs, befintliga PATH-värden skrivs inte över och avinstallation är enkel.

## Begränsning

CLI:t ger medvetet bara diagnostik och korrekt status tills repositoriet innehåller en riktig share-desk-gpt-entrypoint.
