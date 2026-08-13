#requires -version 5.1
[CmdletBinding()]
param([switch]$System)
$ErrorActionPreference = 'Stop'
$AppName = 'share-desk-gpt'
$UserRoot = Join-Path $env:LOCALAPPDATA $AppName
$UserBin = Join-Path $UserRoot 'bin'
$SystemRoot = Join-Path $env:ProgramFiles $AppName
function Remove-PathEntry([string]$Scope, [string]$PathToRemove) {
  $current = [Environment]::GetEnvironmentVariable('Path', $Scope)
  if ($null -eq $current) { return }
  $items = @($current -split ';' | Where-Object { $_ -and $_ -ne $PathToRemove })
  [Environment]::SetEnvironmentVariable('Path', ($items -join ';'), $Scope)
}
Remove-PathEntry 'User' $UserBin
Remove-PathEntry 'User' (Join-Path $UserRoot 'node')
if (Test-Path $UserRoot) { Remove-Item -Recurse -Force $UserRoot }
if ($System) {
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) { throw '-System requires an elevated PowerShell session.' }
  $current = [Environment]::GetEnvironmentVariable('Path','Machine')
  $items = @($current -split ';' | Where-Object { $_ -and $_ -ne $SystemRoot })
  [Environment]::SetEnvironmentVariable('Path', ($items -join ';'), 'Machine')
  if (Test-Path $SystemRoot) { Remove-Item -Recurse -Force $SystemRoot }
}
Write-Host 'share-desk-gpt uninstalled.'
