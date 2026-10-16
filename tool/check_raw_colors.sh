#!/usr/bin/env bash
# Apps read colours from NightOutColors (nightout_core), never hex literals.
set -euo pipefail
cd "$(dirname "$0")/.."
if grep -rnE 'Color\(0x|Color\.fromARGB|Color\.fromRGBO' apps/*/lib; then
  echo "Raw colour in an app. Use context.colors (NightOutColors) from nightout_core." >&2
  exit 1
fi
echo "no raw colours in apps"
