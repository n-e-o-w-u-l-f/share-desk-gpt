# share-desk-gpt

Base d’installation et de CLI multiplateforme pour **share-desk-gpt**.

> **État actuel :** le dépôt public ne fournit pas encore de véritable point d’entrée applicatif. Cette version construit donc la couche d’installation et d’exécution sans inventer de fonctionnalités.

## Fonctionnement

L’installateur détecte le `PATH`, vérifie Node.js/npm/npx, installe Node.js seulement si nécessaire, vérifie le SHA-256 de l’archive et crée la commande `share-desk-gpt` dans le PATH utilisateur. L’installation système est explicite et nécessite des privilèges élevés.

`npx` n’est pas installé séparément : il fait partie de npm via `npx`/`npm exec`.

NixOS utilise Nix au lieu d’écrire dans `/usr/bin`. SteamOS reste en installation utilisateur afin de ne pas modifier son système de base immuable.

## Installation

Linux :

```bash
bash scripts/install.sh
```

Système :

```bash
sudo bash scripts/install.sh --system
```

Windows :

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Vérification :

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

## Plates-formes

Windows x64/ARM64 et Linux x64/ARM64/ARMv7. ARMv7 utilise Node.js 22, car Node.js 24 ne publie plus d’archive Linux ARMv7 actuelle.

Arch Linux, Debian, Ubuntu et Raspberry Pi OS utilisent le runtime local si Node/npm manquent. NixOS utilise Nix. SteamOS privilégie l’installation utilisateur.

## Principe de sécurité

Le mode utilisateur est le choix par défaut : pas de privilège administrateur, pas de modification des fichiers gérés par la distribution et désinstallation simple. Les entrées PATH existantes ne sont jamais écrasées.

## Limite actuelle

Le CLI installé fournit volontairement un diagnostic et un état honnête tant que le véritable point d’entrée applicatif de share-desk-gpt n’est pas présent dans le dépôt public.
