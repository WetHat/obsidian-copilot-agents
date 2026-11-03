#!/bin/sh
# macOS/Linux launcher. All resolution and formatting logic lives in the
# PowerShell sibling, so this script needs PowerShell 7+ (pwsh) on PATH.
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$here/canvas-content.ps1" "$@"
fi
echo "canvas-content: PowerShell 7+ (pwsh) is required on macOS/Linux; install it, or run the .ps1 directly." >&2
exit 1