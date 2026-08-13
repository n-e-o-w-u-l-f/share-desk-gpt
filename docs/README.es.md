# share-desk-gpt

Base multiplataforma de instalación y CLI para **share-desk-gpt**.

> **Estado actual:** el repositorio público todavía no contiene un punto de entrada real de la aplicación. Esta versión construye la capa de instalación y ejecución sin inventar funciones.

## Qué hace

Detecta `PATH`, comprueba Node.js/npm/npx, instala Node.js solo cuando falta, verifica la suma SHA-256 y crea el comando `share-desk-gpt` en el PATH del usuario. La instalación del sistema es explícita y requiere privilegios elevados.

`npx` no se instala por separado: forma parte de npm mediante `npx`/`npm exec`.

NixOS usa Nix en lugar de escribir en `/usr/bin`. SteamOS utiliza instalación por usuario para no modificar su sistema base inmutable.

## Instalación

Linux:

```bash
bash scripts/install.sh
```

Sistema:

```bash
sudo bash scripts/install.sh --system
```

Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Comprobación:

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Plataformas

Windows x64/ARM64 y Linux x64/ARM64/ARMv7. ARMv7 utiliza Node.js 22 porque Node.js 24 ya no publica un binario Linux ARMv7 actual.

Arch Linux, Debian, Ubuntu y Raspberry Pi OS usan el runtime local cuando faltan Node/npm. NixOS usa Nix. SteamOS mantiene la instalación en el ámbito del usuario.

## Principio de estabilidad

La instalación de usuario es el valor predeterminado: no requiere administrador/root, evita modificar archivos gestionados por la distribución y es fácil de desinstalar. Las rutas existentes nunca se sobrescriben.

## Limitación actual

El CLI ofrece deliberadamente diagnóstico y estado real hasta que el repositorio publique el punto de entrada de la aplicación share-desk-gpt.
