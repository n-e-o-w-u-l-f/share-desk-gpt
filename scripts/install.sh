#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

APP_NAME='share-desk-gpt'
NODE24_VERSION='24.18.1'
NODE22_VERSION='22.23.2'
PREFIX_USER="${XDG_DATA_HOME:-$HOME/.local/share}/$APP_NAME"
PREFIX_SYSTEM="/usr/local/share/$APP_NAME"
BIN_USER="${XDG_BIN_HOME:-$HOME/.local/bin}"
LOG_FILE="${TMPDIR:-/tmp}/${APP_NAME}-install.$$.log"
LANG_CODE='auto'
SYSTEM_INSTALL=0
SKIP_DEPS=0

say() { printf '%s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
fatal() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
share-desk-gpt installer

Usage: install.sh [options]
  --lang CODE       en,de,fr,es,nl,da,sv,fi,pl,ru or auto
  --system          install wrapper into a system bin directory (sudo/root may be required)
  --user            force user-local installation (default)
  --skip-deps       do not install Node.js when missing
  --help             show this help
USAGE
}

while (($#)); do
  case "$1" in
    --lang) LANG_CODE="${2:-}"; shift 2 ;;
    --system) SYSTEM_INSTALL=1; shift ;;
    --user) SYSTEM_INSTALL=0; shift ;;
    --skip-deps) SKIP_DEPS=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fatal "Unknown option: $1" ;;
  esac
done

printf 'Installer log: %s\n' "$LOG_FILE" | tee "$LOG_FILE" >/dev/null
exec > >(tee -a "$LOG_FILE") 2>&1
if (( SYSTEM_INSTALL )) && [[ $EUID -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || fatal "--system requires root or sudo."
  extra=()
  if (( SKIP_DEPS )); then extra+=(--skip-deps); fi
  exec sudo -E bash "$0" --lang "$LANG_CODE" --system "${extra[@]}"
fi

command_exists() { command -v "$1" >/dev/null 2>&1; }

select_language() {
  if [[ "$LANG_CODE" != auto ]]; then
    printf '%s' "$LANG_CODE"; return
  fi
  local l="${LANG:-en}"; l="${l%%_*}"; l="${l%%-*}"
  case "$l" in en|de|fr|es|nl|da|sv|fi|pl|ru) printf '%s' "$l" ;; *) printf '%s' en ;; esac
}
LANG_CODE="$(select_language)"

msg() {
  local key="$1"; shift || true
  case "$LANG_CODE:$key" in
    en:start) echo "Starting share-desk-gpt installation.";;
    de:start) echo "Installation von share-desk-gpt wird gestartet.";;
    fr:start) echo "Démarrage de l’installation de share-desk-gpt.";;
    es:start) echo "Iniciando la instalación de share-desk-gpt.";;
    nl:start) echo "De installatie van share-desk-gpt wordt gestart.";;
    da:start) echo "Starter installationen af share-desk-gpt.";;
    sv:start) echo "Startar installationen av share-desk-gpt.";;
    fi:start) echo "Käynnistetään share-desk-gpt-asennus.";;
    pl:start) echo "Rozpoczynanie instalacji share-desk-gpt.";;
    ru:start) echo "Запуск установки share-desk-gpt.";;
    en:path) echo "Detected PATH entries:";;
    de:path) echo "Erkannte PATH-Einträge:";;
    fr:path) echo "Entrées PATH détectées :";;
    es:path) echo "Entradas PATH detectadas:";;
    nl:path) echo "Gedetecteerde PATH-items:";;
    da:path) echo "Registrerede PATH-poster:";;
    sv:path) echo "Identifierade PATH-poster:";;
    fi:path) echo "Havaitut PATH-merkinnät:";;
    pl:path) echo "Wykryte wpisy PATH:";;
    ru:path) echo "Обнаруженные записи PATH:";;
    en:node) echo "Node.js is missing; installing a user-local runtime.";;
    de:node) echo "Node.js fehlt; eine benutzerlokale Runtime wird installiert.";;
    fr:node) echo "Node.js est absent ; installation d’un runtime local à l’utilisateur.";;
    es:node) echo "Falta Node.js; se instalará un runtime local del usuario.";;
    nl:node) echo "Node.js ontbreekt; er wordt een lokale runtime voor de gebruiker geïnstalleerd.";;
    da:node) echo "Node.js mangler; en lokal runtime installeres for brugeren.";;
    sv:node) echo "Node.js saknas; en användarlokal runtime installeras.";;
    fi:node) echo "Node.js puuttuu; käyttäjäkohtainen runtime asennetaan.";;
    pl:node) echo "Brak Node.js; zostanie zainstalowane środowisko lokalne użytkownika.";;
    ru:node) echo "Node.js отсутствует; будет установлена локальная среда пользователя.";;
    en:done) echo "Installation completed.";;
    de:done) echo "Installation abgeschlossen.";;
    fr:done) echo "Installation terminée.";;
    es:done) echo "Instalación completada.";;
    nl:done) echo "Installatie voltooid.";;
    da:done) echo "Installationen er fuldført.";;
    sv:done) echo "Installationen är klar.";;
    fi:done) echo "Asennus valmis.";;
    pl:done) echo "Instalacja zakończona.";;
    ru:done) echo "Установка завершена.";;
    *) echo "$key";;
  esac
}

msg start
say "Language: $LANG_CODE"
say "OS: $(uname -s)"
say "Kernel: $(uname -r)"
say "Architecture: $(uname -m)"
msg path
printenv | awk -F= 'BEGIN {IGNORECASE=1} $1 ~ /PATH/ {print "  " $1 "=" $2}' | sort
printf '%s\n' "${PATH:-}" | tr ':' '\n' | sed 's/^/  PATH: /'

is_nixos=0
is_steamos=0
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ "${ID:-}" == nixos ]] && is_nixos=1
  [[ "${ID:-}" == steamos || "${ID_LIKE:-}" == *arch* && "${PRETTY_NAME:-}" == *SteamOS* ]] && is_steamos=1
fi

ensure_path_user() {
  mkdir -p "$BIN_USER"
  local rc="$HOME/.profile"
  touch "$rc"
  if ! grep -Fq "export PATH=\"$BIN_USER:\$PATH\"" "$rc"; then
    printf '\n# share-desk-gpt\nexport PATH="%s:$PATH"\n' "$BIN_USER" >> "$rc"
  fi
  export PATH="$BIN_USER:$PATH"
}

sha256_of() {
  if command_exists sha256sum; then sha256sum "$1" | awk '{print $1}';
  elif command_exists shasum; then shasum -a 256 "$1" | awk '{print $1}';
  else return 1; fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo x64;;
    aarch64|arm64) echo arm64;;
    armv7l|armv7|armhf) echo armv7l;;
    ppc64le) echo ppc64le;;
    s390x) echo s390x;;
    *) return 1;;
  esac
}

install_node_local() {
  local arch="$1" version="$NODE24_VERSION" node_arch="$arch"
  if [[ "$arch" == armv7l ]]; then version="$NODE22_VERSION"; fi
  local archive="node-v${version}-linux-${node_arch}.tar.xz"
  local url="https://nodejs.org/download/release/v${version}/${archive}"
  local tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  command_exists curl || fatal "curl is required to download Node.js."
  command_exists tar || fatal "tar is required to install Node.js."
  command_exists xz || fatal "xz is required to unpack Node.js."
  msg node
  curl --fail --location --proto '=https' --tlsv1.2 --retry 3 --retry-delay 2 -o "$tmp/$archive" "$url"
  local expected actual
  case "$version:$archive" in
    24.18.1:node-v24.18.1-linux-x64.tar.xz) expected='d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0';;
    24.18.1:node-v24.18.1-linux-arm64.tar.xz) expected='7201e3a09dc825bac57867c81913e2b8f0ef87d04cb9082af4cda82f6ff3d88c';;
    24.18.1:node-v24.18.1-linux-ppc64le.tar.xz) expected='c47812c13862be7f6e71194c434c4d78a99096e72efb9c31a2627437e056d669';;
    24.18.1:node-v24.18.1-linux-s390x.tar.xz) expected='acf57bd726f35afc2ba8475194e5a8bd532c00e1a3b2436295b2fbdde199d0e9';;
    22.23.2:node-v22.23.2-linux-armv7l.tar.xz) expected='ef8f26a3de19acd8c23548e6c3cfc2052610b0e67abb5fd64dbd92c8b1c1245b';;
    *) fatal "No pinned checksum is available for $archive";;
  esac
  actual="$(sha256_of "$tmp/$archive")" || fatal "No SHA-256 implementation found."
  [[ "$expected" == "$actual" ]] || fatal "SHA-256 verification failed for $archive"
  local prefix="$PREFIX_USER"
  if (( SYSTEM_INSTALL )); then prefix="$PREFIX_SYSTEM"; fi
  rm -rf "$prefix/node" "$prefix/node.tmp"
  mkdir -p "$prefix"
  tar -xJf "$tmp/$archive" -C "$prefix"
  mv "$prefix/node-v${version}-linux-${node_arch}" "$prefix/node.tmp"
  mv "$prefix/node.tmp" "$prefix/node"
  if (( ! SYSTEM_INSTALL )); then ensure_path_user; else export PATH="$prefix/node/bin:$PATH"; fi
}

if (( SYSTEM_INSTALL )) && (( is_nixos || is_steamos )); then
  fatal "Stable system installation is intentionally disabled on NixOS and SteamOS. Use the user-local installer."
fi

if ! command_exists node || ! command_exists npm || ! command_exists npx; then
  if (( SKIP_DEPS )); then fatal "Node.js/npm are missing and --skip-deps was requested."; fi
  arch="$(detect_arch)" || fatal "Unsupported Linux architecture: $(uname -m)"
  if (( is_nixos )); then
    if command_exists nix; then
      say "NixOS detected: using the Nix package manager instead of writing /usr/bin."
      nix profile install nixpkgs#nodejs || nix profile install nixpkgs#nodejs
      if [[ -x "$HOME/.nix-profile/bin/node" ]]; then export PATH="$HOME/.nix-profile/bin:$PATH"; fi
    else
      fatal "NixOS detected but the nix command is unavailable. Install Nix first or use a prebuilt image with Nix enabled."
    fi
  else
    install_node_local "$arch"
  fi
fi

command_exists node || fatal "Node.js is still unavailable after installation."
command_exists npm || fatal "npm is still unavailable after installation."

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if (( ! SYSTEM_INSTALL )); then ensure_path_user; fi
if (( SYSTEM_INSTALL )); then
  mkdir -p "$PREFIX_SYSTEM"
  cp "$repo_root/bin/share-desk-gpt.js" "$PREFIX_SYSTEM/share-desk-gpt.js"
  installed_cli="$PREFIX_SYSTEM/share-desk-gpt.js"
  wrapper="$PREFIX_SYSTEM/share-desk-gpt"
  system_bin='/usr/local/bin'
  [[ -d /usr/bin && -w /usr/bin ]] && system_bin='/usr/bin'
else
  mkdir -p "$PREFIX_USER"
  cp "$repo_root/bin/share-desk-gpt.js" "$PREFIX_USER/share-desk-gpt.js"
  installed_cli="$PREFIX_USER/share-desk-gpt.js"
  wrapper="$BIN_USER/share-desk-gpt"
fi
node_path="$(command -v node)"
node_bin="$(dirname "$node_path")"
cat > "$wrapper" <<EOF_WRAPPER
#!/usr/bin/env bash
set -euo pipefail
export PATH="$node_bin:\$PATH"
exec "$node_path" "$installed_cli" "\$@"
EOF_WRAPPER
chmod +x "$wrapper"

if (( SYSTEM_INSTALL )); then
  install -d -m 0755 "$system_bin"
  install -m 0755 "$wrapper" "$system_bin/share-desk-gpt"
  say "Installed system-wide command: $system_bin/share-desk-gpt"
fi

msg done
say "Run: share-desk-gpt --doctor"
