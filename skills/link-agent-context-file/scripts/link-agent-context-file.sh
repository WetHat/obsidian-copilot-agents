#!/bin/sh
# macOS/Linux launcher. The resolution logic lives in the PowerShell sibling,
# so this script needs PowerShell 7+ (pwsh) on PATH.
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if command -v pwsh >/dev/null 2>&1; then
  exec pwsh -NoProfile -File "$here/link-agent-context-file.ps1" "$@"
fi
echo "link-agent-context-file: PowerShell 7+ (pwsh) is required on macOS/Linux; install it, or run the .ps1 directly." >&2
exit 1
