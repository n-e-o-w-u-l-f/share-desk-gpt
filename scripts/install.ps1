#requires -version 5.1
[CmdletBinding()]
param(
  [ValidateSet('auto','en','de','fr','es','nl','da','sv','fi','pl','ru')]
  [string]$Lang = 'auto',
  [switch]$System,
  [switch]$SkipDeps
)

$ErrorActionPreference = 'Stop'
$AppName = 'share-desk-gpt'
$NodeVersion = '24.18.1'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$UserRoot = Join-Path $env:LOCALAPPDATA $AppName
$SystemRoot = Join-Path $env:ProgramFiles $AppName
$UserBin = Join-Path $UserRoot 'bin'
$Log = Join-Path $env:TEMP "$AppName-install-$PID.log"

function Write-Log([string]$Text) { $Text | Tee-Object -FilePath $Log -Append | Write-Host }
function Fail([string]$Text) { throw $Text }

if ($Lang -eq 'auto') {
  $candidate = ($env:LANG, $env:LC_ALL, (Get-Culture).Name | Where-Object { $_ })[0]
  $code = (($candidate -replace '_.*$','') -replace '-.*$','').ToLowerInvariant()
  $Lang = if ($code -in @('en','de','fr','es','nl','da','sv','fi','pl','ru')) { $code } else { 'en' }
}

$msg = @{
  start = @{ en='Starting share-desk-gpt installation.'; de='Installation von share-desk-gpt wird gestartet.'; fr='Démarrage de l’installation de share-desk-gpt.'; es='Iniciando la instalación de share-desk-gpt.'; nl='De installatie van share-desk-gpt wordt gestart.'; da='Starter installationen af share-desk-gpt.'; sv='Startar installationen av share-desk-gpt.'; fi='Käynnistetään share-desk-gpt-asennus.'; pl='Rozpoczynanie instalacji share-desk-gpt.'; ru='Запуск установки share-desk-gpt.' },
  node = @{ en='Node.js/npm is missing or incomplete; installing a verified runtime.'; de='Node.js fehlt; eine benutzerlokale Runtime wird installiert.'; fr='Node.js est absent ; installation d’un runtime local à l’utilisateur.'; es='Falta Node.js; se instalará un runtime local del usuario.'; nl='Node.js ontbreekt; er wordt een lokale runtime voor de gebruiker geïnstalleerd.'; da='Node.js mangler; en lokal runtime installeres for brugeren.'; sv='Node.js saknas; en användarlokal runtime installeras.'; fi='Node.js puuttuu; käyttäjäkohtainen runtime asennetaan.'; pl='Brak Node.js; zostanie zainstalowane środowisko lokalne użytkownika.'; ru='Node.js отсутствует; будет установлена локальная среда пользователя.' },
  done = @{ en='Installation completed.'; de='Installation abgeschlossen.'; fr='Installation terminée.'; es='Instalación completada.'; nl='Installatie voltooid.'; da='Installationen er fuldført.'; sv='Installationen är klar.'; fi='Asennus valmis.'; pl='Instalacja zakończona.'; ru='Установка завершена.' }
}
function T([string]$Key) { $msg[$Key][$Lang] }
Write-Log (T 'start')
Write-Log "Language: $Lang"
Write-Log "OS: $([Environment]::OSVersion.VersionString)"
Write-Log "Architecture: $([Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE'))"
Write-Log 'PATH-related environment variables:'
Get-ChildItem Env: | Where-Object { $_.Name -match 'PATH' } | Sort-Object Name | ForEach-Object { Write-Log "  $($_.Name)=$($_.Value)" }
Write-Log 'User PATH:'
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
if ($userPath) { $userPath.Split(';') | ForEach-Object { if ($_){ Write-Log "  $_" } } }
Write-Log 'Effective PATH:'
$env:Path.Split(';') | ForEach-Object { if ($_){ Write-Log "  $_" } }

function Add-UserPath([string]$PathToAdd) {
  $current = [Environment]::GetEnvironmentVariable('Path','User')
  $items = @($current -split ';' | Where-Object { $_ })
  if ($items -notcontains $PathToAdd) { $items += $PathToAdd }
  [Environment]::SetEnvironmentVariable('Path', ($items -join ';'), 'User')
  if ($env:Path -notlike "*$PathToAdd*") { $env:Path = "$PathToAdd;$env:Path" }
}

if ($System) {
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) { Fail '-System requires an elevated PowerShell session.' }
}

function Install-NodeLocal {
  param([string]$Architecture)
  $asset = switch ($Architecture) {
    'AMD64' { "node-v$NodeVersion-win-x64.zip" }
    'ARM64' { "node-v$NodeVersion-win-arm64.zip" }
    default { Fail "Unsupported Windows architecture: $Architecture" }
  }
  $url = "https://nodejs.org/download/release/v$NodeVersion/$asset"
  $tmp = Join-Path $env:TEMP "$AppName-node-$PID"
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  $zip = Join-Path $tmp $asset
  Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  $expected = switch ($asset) {
    "node-v24.18.1-win-x64.zip" { 'ec56b84a7551893ab2324ebdfdc4ab974a63b4781162600b68a1293cc3e53765' }
    "node-v24.18.1-win-arm64.zip" { 'ffbc7d3e1baf6804f7431ff94f19b9a885a650568c93ea4ccb1bb0038f6af825' }
    default { Fail "No pinned checksum is available for $asset" }
  }
  $actual = (Get-FileHash -Algorithm SHA256 -Path $zip).Hash.ToLowerInvariant()
  if ($expected.ToLowerInvariant() -ne $actual) { Fail "SHA-256 verification failed for $asset" }
  $targetRoot = if ($System) { $SystemRoot } else { $UserRoot }
  if (Test-Path $targetRoot) { Remove-Item -Recurse -Force $targetRoot }
  New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
  $source = Join-Path $tmp ($asset -replace '\.zip$','')
  Move-Item -Path $source -Destination (Join-Path $targetRoot 'node') -Force
  if (-not $System) { Add-UserPath (Join-Path $targetRoot 'node') } else { $env:Path = "$(Join-Path $targetRoot 'node');$env:Path" }
}

$node = Get-Command node.exe -ErrorAction SilentlyContinue
$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue
$npx = Get-Command npx.cmd -ErrorAction SilentlyContinue
if (-not $node -or -not $npm -or -not $npx) {
  if ($SkipDeps) { Fail 'Node.js/npm are missing and -SkipDeps was requested.' }
  Write-Log (T 'node')
  Install-NodeLocal ([Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE'))
}

$node = Get-Command node.exe -ErrorAction Stop
$npm = Get-Command npm.cmd -ErrorAction Stop
$npx = Get-Command npx.cmd -ErrorAction Stop
if (-not $System) { Add-UserPath (Join-Path $UserRoot 'node') }

$wrapperRoot = if ($System) { $SystemRoot } else { $UserBin }
New-Item -ItemType Directory -Force -Path $wrapperRoot | Out-Null
$installedCliRoot = if ($System) { $SystemRoot } else { $UserRoot }
New-Item -ItemType Directory -Force -Path $installedCliRoot | Out-Null
Copy-Item (Join-Path $Root 'bin/share-desk-gpt.js') (Join-Path $installedCliRoot 'share-desk-gpt.js') -Force
$wrapper = Join-Path $wrapperRoot 'share-desk-gpt.cmd'
@"
@echo off
"$($node.Source)" "$installedCliRoot\share-desk-gpt.js" %*
"@ | Set-Content -Encoding ASCII $wrapper
if ($System) {
  $machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
  if (($machinePath -split ';') -notcontains $wrapperRoot) { [Environment]::SetEnvironmentVariable('Path', "$wrapperRoot;$machinePath", 'Machine') }
  Write-Log "Installed system-wide command: $wrapper"
} else { Add-UserPath $UserBin }

Write-Log (T 'done')
Write-Log 'Run: share-desk-gpt --doctor'
