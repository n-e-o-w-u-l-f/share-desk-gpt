# share-desk-gpt

Cross-platform installer and CLI foundation for **share-desk-gpt**.

> **Current repository status:** the public repository currently contains no application entrypoint beyond the repository documentation. This project therefore provides the installation/runtime layer without inventing application behavior.

## Documentation languages

- [English](README.md)
- [Deutsch](docs/README.de.md)
- [Français](docs/README.fr.md)
- [Español](docs/README.es.md)
- [Nederlands](docs/README.nl.md)
- [Dansk](docs/README.da.md)
- [Svenska](docs/README.sv.md)
- [Suomi](docs/README.fi.md)
- [Polski](docs/README.pl.md)
- [Русский](docs/README.ru.md)

## What it does

The installer is designed to be predictable and reversible:

- detects the effective `PATH` and PATH-related environment variables;
- checks whether Node.js and npm are already usable;
- installs a pinned, verified Node.js runtime only when needed;
- relies on npm's bundled `npx`/`npm exec` instead of installing a separate `npx` package;
- installs `share-desk-gpt` into the user's command path by default;
- supports an explicit system-wide mode when elevated privileges are appropriate;
- keeps NixOS and SteamOS on their safer user-local paths instead of modifying immutable or declarative system locations;
- provides localized installer messages for English, German, French, Spanish, Dutch, Danish, Swedish, Finnish, Polish and Russian.

## Requirements

### Windows

Supported architectures: x64 and ARM64. Windows 10/11 are the intended target. The user installer requires no administrator rights; system installation requires an elevated PowerShell.

### Linux

The installer targets glibc-based Linux on x64, ARM64 and ARMv7. ARMv7 uses the latest available Node.js 22 LTS build because current Node.js 24 binaries no longer publish an ARMv7 Linux archive. Node.js 24 LTS is used for x64/ARM64/ppc64le/s390x.

| Distribution | Strategy | Stability note |
|---|---|---|
| Arch Linux | user-local Node bundle | avoids unnecessary pacman changes |
| Debian | user-local Node bundle when Node/npm are missing | optional distro packages remain compatible |
| Ubuntu | user-local Node bundle when Node/npm are missing | optional distro packages remain compatible |
| Raspberry Pi OS | user-local Node bundle | APT remains the system package manager |
| NixOS | `nix profile install nixpkgs#nodejs` | do not write to `/usr/bin` |
| SteamOS / Steam Deck | user-local Node bundle | do not modify the immutable base system |

Raspberry Pi OS is Debian-based. SteamOS is Arch-based, but Valve documents its immutable/read-only system image and warns that pacman-installed software can be removed by system updates. NixOS is declarative and should be managed through Nix rather than conventional `/usr/bin` mutation.

## Install

### Linux

From a checkout:

```bash
bash scripts/install.sh
```

Choose a language explicitly when needed:

```bash
bash scripts/install.sh --lang de
```

Install the command system-wide on a conventional Linux system:

```bash
sudo bash scripts/install.sh --system
```

For NixOS and SteamOS, use the default user installation. A system installation is deliberately rejected because it is less stable on those platforms.

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Or use the convenience launcher:

```cmd
install.cmd
```

System-wide installation requires an elevated PowerShell:

```powershell
.\scripts\install.ps1 -System
```

## Verify

```text
share-desk-gpt --doctor
share-desk-gpt --version
```

`--doctor` reports the operating system, architecture, Node/npm/npx availability and effective PATH entries.

## PATH handling

The installer never overwrites an existing PATH. It appends only the directories it owns, and it avoids `setx` for PATH mutation on Windows because that command has legacy truncation/expansion pitfalls. Persistent Windows changes use the environment API instead.

On Linux, the default command directory is `$XDG_BIN_HOME` or `~/.local/bin`; the installer also adds that directory to `~/.profile` when needed. A system installation uses `/usr/local/bin` by default and only falls back to `/usr/bin` when that directory is writable.

## Dependency policy

The installer checks for **usable** `node`, `npm`, and `npx` rather than assuming that a package name equals a working command. Missing Node.js/npm causes installation of the pinned runtime. `npx` is treated as part of npm (`npx`/`npm exec`) and is never installed as an unrelated global package.

For downloaded Node.js archives, the installer uses HTTPS, retries transient failures and verifies a pinned SHA-256 hash before extraction. Runtime versions and hashes are intentionally visible in the installer source so upgrades are reviewable.

## Why the installer is deliberately conservative

The safest default is a user-local installation. It works without root/admin rights, avoids modifying distribution-managed files and is reversible.

System-wide installation is opt-in because `/usr/bin`, `/bin`, Windows machine PATH and immutable operating systems are higher-risk targets.

NixOS and SteamOS are not treated as ordinary Arch/Debian systems. Their system-management model is different, so forcing a traditional `/usr/bin` installation would make the result less reliable.

## CI

GitHub Actions covers:

- Windows and Ubuntu CLI smoke tests;
- Bash syntax checks in a clean Ubuntu container;
- installer help-mode validation;
- basic distro-detection fixtures.

The workflow uses least-privilege `contents: read`, concurrency cancellation and `actions/setup-node` caching. GitHub Actions dependencies are monitored by Dependabot.

## Repository structure

```text
bin/                         CLI entrypoint
scripts/install.sh           Linux installer
scripts/install.ps1          Windows installer
scripts/uninstall.sh         Linux uninstall
scripts/uninstall.ps1        Windows uninstall
tests/                       local smoke/fixture tests
.github/workflows/ci.yml     CI rules
.github/dependabot.yml       Actions dependency updates
docs/                        translated READMEs
```

## Important limitation

The installer foundation is complete, but the public repository currently does not expose the actual share-desk-gpt application entrypoint. The command installed here therefore provides diagnostics and a truthful status message instead of pretending that an application exists.

When the application entrypoint is added, the same installer can launch it without changing the platform/bootstrap architecture.

See [`docs/PLATFORMS.md`](docs/PLATFORMS.md) for the platform-by-platform rationale and the theoretical Linux support boundary.

## References

- Node.js releases and LTS policy: https://nodejs.org/en/about/previous-releases
- Node.js 24.18.1 release: https://nodejs.org/dist/v24.18.1/
- Node.js 22.23.2 release: https://nodejs.org/dist/v22.23.2/
- npm `npx` / `npm exec`: https://docs.npmjs.com/cli/v11/commands/npx
- Windows environment variables: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables
- Raspberry Pi OS: https://www.raspberrypi.com/documentation/computers/os.html
- NixOS Node.js: https://wiki.nixos.org/wiki/Node.js
- SteamOS: https://store.steampowered.com/steamos/
- Steam Deck FAQ / immutable filesystem: https://partner.steamgames.com/doc/steamhardware/steamdeck/faq
