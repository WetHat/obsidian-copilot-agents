#!/bin/sh
set -eu
if ! command -v pwsh >/dev/null 2>&1; then
    printf '%s\n' 'Error: Install PowerShell 7 (pwsh) to invoke this skill.' >&2
    exit 1
fi
skill_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
exec pwsh -NoLogo -NoProfile -NonInteractive -File "$skill_dir/infer-content-type.ps1" "$@"
