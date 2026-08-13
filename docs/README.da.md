# share-desk-gpt

Multiplatform installer- og CLI-grundlag til **share-desk-gpt**.

> **Status:** Det offentlige repository indeholder endnu ikke et egentligt application-entrypoint. Denne version bygger derfor installations- og runtime-laget uden at opfinde funktioner.

## Funktion

Installeren finder `PATH`, kontrollerer Node.js/npm/npx, installerer kun Node.js ved behov, kontrollerer SHA-256 og opretter kommandoen `share-desk-gpt` i brugerens PATH.

`npx` installeres ikke separat; det følger med npm via `npx`/`npm exec`.

NixOS håndteres gennem Nix. SteamOS bruger lokal brugerinstallation for ikke at ændre det immutable basissystem.

## Installation

Linux:

```bash
bash scripts/install.sh
```

Systemdækkende:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Kontroller:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Platforme

Windows x64/ARM64 samt Linux x64/ARM64/ARMv7. ARMv7 bruger Node.js 22, fordi Node.js 24 ikke længere udgiver en aktuel Linux ARMv7-build.

## Stabilitet

Brugerinstallation er standard: ingen root/admin, ingen overskrivning af eksisterende PATH og nem afinstallation. NixOS og SteamOS behandles ikke som almindelige Linux-systemer.

## Begrænsning

CLI'en giver bevidst kun diagnostik og reel status, indtil den offentlige repository får et egentligt share-desk-gpt-entrypoint.
