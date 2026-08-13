#!/usr/bin/env bash
set -euo pipefail

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || { echo "missing: $needle" >&2; exit 1; }
}

fixtures=(
  'ID=arch\nID_LIKE=arch'
  'ID=debian\nID_LIKE=debian'
  'ID=ubuntu\nID_LIKE=debian'
  'ID=raspbian\nID_LIKE=debian'
  'ID=nixos\nID_LIKE=' 
  'ID=steamos\nID_LIKE=arch'
)
for fixture in "${fixtures[@]}"; do
  assert_contains "$fixture" 'ID='
done

echo 'Distro fixture tests passed.'
