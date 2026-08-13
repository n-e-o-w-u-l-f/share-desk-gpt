# share-desk-gpt

Plattformübergreifende Installer- und CLI-Basis für **share-desk-gpt**.

> **Aktueller Stand:** Das öffentliche Repository enthält derzeit keine eigentliche Anwendungslogik bzw. keinen Startpunkt. Dieses Projekt baut deshalb ausschließlich die belastbare Installations- und Laufzeitbasis auf und erfindet keine nicht vorhandenen Funktionen.

## Was der Installer macht

- ermittelt die effektive `PATH`-Umgebung und PATH-bezogene Variablen;
- prüft, ob Node.js, npm und npx tatsächlich nutzbar sind;
- installiert nur bei Bedarf eine festgelegte und per SHA-256 geprüfte Node.js-Version;
- behandelt `npx` als Bestandteil von npm (`npx`/`npm exec`), statt ein separates Paket zu installieren;
- legt `share-desk-gpt` standardmäßig im Benutzer-PATH ab;
- bietet ausdrücklich eine Systeminstallation mit erhöhten Rechten an;
- behandelt NixOS und SteamOS absichtlich nicht wie normale Linux-Installationen;
- bietet Installer-Texte auf Englisch, Deutsch, Französisch, Spanisch, Niederländisch, Dänisch, Schwedisch, Finnisch, Polnisch und Russisch.

## Installation

Linux:

```bash
bash scripts/install.sh
```

Systemweit auf einem normalen Linux-System:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Prüfen:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

Für NixOS und SteamOS wird die Benutzerinstallation empfohlen und eine traditionelle Systeminstallation absichtlich abgelehnt.

## Unterstützte Plattformen

Windows x64/ARM64 sowie Linux x64/ARM64/ARMv7. ARMv7 verwendet Node.js 22, weil Node.js 24 kein aktuelles ARMv7-Linux-Binary mehr veröffentlicht.

Arch, Debian, Ubuntu und Raspberry Pi OS verwenden bei fehlender Node/npm-Installation das lokale Runtime-Bundle. NixOS nutzt Nix. SteamOS bleibt bei einer Benutzerinstallation, damit das immutable Basissystem nicht verändert wird.

## Warum diese Strategie

Die Standardinstallation benötigt weder Administratorrechte noch Root. Dadurch bleiben distributionsverwaltete Dateien unangetastet und die Installation ist leicht rückgängig zu machen.

PATH-Einträge werden nicht überschrieben, sondern nur ergänzt. Unter Windows wird die dauerhafte Umgebungsvariable über die Windows-API gesetzt; unter Linux wird standardmäßig `~/.local/bin` verwendet.

## Einschränkung

Sobald das eigentliche share-desk-gpt-Programm einen echten Einstiegspunkt erhält, kann dieselbe Installerbasis diesen starten. Der aktuelle CLI-Befehl meldet deshalb bewusst nur den vorhandenen Installationsstatus und die Laufzeitdiagnose.
