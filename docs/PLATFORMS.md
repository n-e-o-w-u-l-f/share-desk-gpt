# Platform research and support model

## Windows

**Supported:** Windows 10/11 on x64 and ARM64.

The installer prefers the official portable Node.js ZIP instead of the MSI. The ZIP avoids a machine-wide installer transaction and lets the default user installation work without elevation. The Node.js 24.18.1 archive publishes Windows x64 and ARM64 ZIPs and is an LTS security release.

Persistent PATH changes use the Windows environment API. Windows maintains user and machine environment scopes separately, and persistent changes can be written with `Environment.SetEnvironmentVariable`.

## Arch Linux

Arch uses `pacman`, and Arch packages Node.js and npm separately. A distro-native install is valid, but it is not the installer default because the project can avoid changing the system package database by using a user-local verified Node bundle.

## Debian

Debian ships Node.js through the normal package repositories. Debian 13 currently provides Node.js 20, while other suites provide other major versions. The project therefore does not assume that the distro package is new enough; it checks the actual runtime and falls back to the pinned local runtime when needed.

## Ubuntu

Ubuntu follows the Debian packaging model for Node.js. The installer treats Ubuntu like Debian: use an existing compatible Node.js/npm first, otherwise install the project-managed runtime locally instead of changing unrelated system packages.

## Raspberry Pi OS

Raspberry Pi OS is Debian-based and officially recommends APT for package management. Current Raspberry Pi OS releases are based on Debian Trixie. This makes a user-local runtime a good default: it does not conflict with APT ownership while still working with the standard filesystem model.

ARM architecture matters. Node.js 24 publishes Linux ARM64, but the current v24 archive does not publish ARMv7. Node.js 22.23.2 still publishes a Linux ARMv7 archive, so the installer uses Node.js 22 for ARMv7 devices.

## NixOS

NixOS is intentionally not treated as a normal mutable Linux distribution. The official NixOS Node.js guidance uses `environment.systemPackages = with pkgs; [ nodejs ];` for declarative system configuration, and Nix provides `nix profile install` for profile-based installation. The installer therefore uses `nix profile install nixpkgs#nodejs` when Nix is already available and refuses a traditional `/usr/bin` system mode.

ARM support is also different: NixOS has full upstream AArch64 support, while ARMv6/ARMv7 are more build-oriented and do not have the same binary-cache coverage.

## SteamOS / Steam Deck

SteamOS is Arch-based, but it is not equivalent to ordinary Arch Linux. Valve documents a read-only/immutable operating-system image and recommends application installation methods that do not modify the base image; Valve also warns that pacman-installed software may be removed by future SteamOS updates.

For this reason the installer deliberately defaults to a user-local runtime on SteamOS and rejects stable system installation. The practical target is Desktop Mode with a normal user home directory. Valve explicitly supports switching to Desktop Mode and installing additional software there.

## Other Linux distributions: theoretical support

The installer architecture can support any Linux distribution that satisfies one of these models:

1. **glibc Linux + supported Node.js binary architecture.** The project can use the pinned official Node archive and needs normal user-space tools (`curl`, `tar`, `xz`, a SHA-256 tool).
2. **NixOS.** Use the Nix package model rather than a mutable `/usr/bin` install.
3. **musl or unusual libc / architecture.** The official Node.js archive may not be directly runnable. Such systems need a distribution-specific Node.js package or a dedicated runtime adapter.

Therefore “Linux compatible” is not a claim that every distribution is equally supported. The installer can be made broadly portable, but the actual share-desk-gpt application may impose additional native-library, GUI, GPU, browser or filesystem requirements that cannot be inferred from the current public repository.

## Current supported target matrix

| Target | Installer status | Recommended mode |
|---|---|---|
| Windows x64 | supported | user |
| Windows ARM64 | supported | user |
| Arch Linux x64/ARM64/ppc64le/s390x | supported runtime path | user |
| Debian x64/ARM64/ARMv7 | supported runtime path | user |
| Ubuntu x64/ARM64/ARMv7 | supported runtime path | user |
| Raspberry Pi OS ARM64 | supported runtime path | user |
| Raspberry Pi OS ARMv7 | supported using Node.js 22 | user |
| NixOS AArch64 | supported via Nix | user/profile |
| SteamOS / Steam Deck | supported user-local | user |
| Alpine/musl | not claimed as direct binary support | dedicated adapter required |
| NixOS ARMv7 | not claimed as binary-cache-equivalent | build/profile-specific |
