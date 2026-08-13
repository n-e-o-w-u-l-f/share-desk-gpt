# share-desk-gpt

Multiplatforme installer- en CLI-basis voor **share-desk-gpt**.

> **Huidige status:** de openbare repository bevat nog geen echte applicatie-entrypoint. Deze versie bouwt daarom alleen de installatie- en runtime-laag en verzint geen functionaliteit.

## Wat doet de installer?

De installer detecteert `PATH`, controleert Node.js/npm/npx, installeert Node.js alleen wanneer dat nodig is, controleert de SHA-256-hash en maakt het commando `share-desk-gpt` in het gebruikers-PATH. Een systeeminstallatie is expliciet en vereist verhoogde rechten.

`npx` wordt niet apart geïnstalleerd: het hoort bij npm via `npx`/`npm exec`.

NixOS gebruikt Nix in plaats van `/usr/bin` te wijzigen. SteamOS gebruikt een gebruikersinstallatie om het onveranderlijke basissysteem niet aan te passen.

## Installatie

Linux:

```bash
bash scripts/install.sh
```

Systeem:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Controleren:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Platforms

Windows x64/ARM64 en Linux x64/ARM64/ARMv7. Voor ARMv7 wordt Node.js 22 gebruikt omdat Node.js 24 geen actuele Linux ARMv7-build meer publiceert.

Arch Linux, Debian, Ubuntu en Raspberry Pi OS gebruiken de lokale runtime als Node/npm ontbreekt. NixOS gebruikt Nix. SteamOS blijft bij een gebruikersinstallatie.

## Stabiliteitsprincipe

De gebruikersinstallatie is standaard: geen root/admin nodig, geen onnodige wijziging van distributiebestanden en eenvoudig te verwijderen. Bestaande PATH-inhoud wordt nooit overschreven.

## Huidige beperking

De geïnstalleerde CLI geeft bewust alleen diagnose en een eerlijke status totdat de openbare repository een echte share-desk-gpt-entrypoint bevat.
