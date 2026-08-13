# share-desk-gpt

Wieloplatformowa baza instalatora i CLI dla **share-desk-gpt**.

> **Aktualny stan:** publiczne repozytorium nie zawiera jeszcze właściwego punktu wejścia aplikacji. Ta wersja buduje więc tylko warstwę instalacji i runtime, bez wymyślania brakujących funkcji.

## Co robi instalator

Wykrywa `PATH`, sprawdza Node.js/npm/npx, instaluje Node.js tylko wtedy, gdy jest potrzebny, weryfikuje SHA-256 i tworzy polecenie `share-desk-gpt` w PATH użytkownika.

`npx` nie jest instalowany osobno, ponieważ jest częścią npm (`npx`/`npm exec`).

NixOS korzysta z Nix zamiast modyfikować `/usr/bin`. SteamOS korzysta z instalacji użytkownika, aby nie zmieniać niezmiennego systemu bazowego.

## Instalacja

Linux:

```bash
bash scripts/install.sh
```

Systemowo:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Sprawdzenie:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Platformy

Windows x64/ARM64 oraz Linux x64/ARM64/ARMv7. ARMv7 używa Node.js 22, ponieważ Node.js 24 nie publikuje już aktualnego binarium Linux ARMv7.

## Stabilność

Instalacja użytkownika jest domyślna: nie wymaga root/admin, nie nadpisuje istniejącego PATH i można ją łatwo usunąć. NixOS i SteamOS są obsługiwane zgodnie z ich własnym modelem zarządzania systemem.

## Ograniczenie

CLI celowo pokazuje tylko diagnostykę i rzeczywisty stan, dopóki publiczne repozytorium nie doda właściwego entrypointu share-desk-gpt.
