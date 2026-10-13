#!/bin/sh
set -eu

fail() {
    printf '%s\n' "Error: $1" >&2
    exit 1
}

if ! command -v pwsh >/dev/null 2>&1; then
    fail 'PowerShell 7+ (pwsh) is required; no dependencies were installed.'
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
    fail 'Set and export OPENAI_API_KEY before invoking this skill.'
fi

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
script_path="$script_dir/infer-content-type.ps1"
[ -r "$script_path" ] || fail 'The updated infer-content-type.ps1 script is missing or unreadable.'
[ -r "$script_dir/../references/type-definitions.json" ] || fail 'The companion type-definitions.json file is missing or unreadable.'

case "$#" in
    0)
        [ ! -t 0 ] || fail 'Supply Markdown through redirected stdin or -content <text>.'
        # A sentinel prevents command substitution from stripping trailing newlines.
        content=$(cat && printf '.') || fail 'Could not read Markdown from stdin.'
        content=${content%.}
        ;;
    1)
        case "$1" in
            -[[:alpha:]]*|--[[:alpha:]]*) fail 'Unsupported argument; use redirected stdin, one content argument, or -content <text>; -TimeoutSec is no longer supported.' ;;
        esac
        content=$1
        ;;
    2)
        case "$1" in
            -content|-Content) content=$2 ;;
            *) fail 'Unsupported argument; only -content <text> is supported; -TimeoutSec is no longer supported.' ;;
        esac
        ;;
    *) fail 'Unsupported arguments; use redirected stdin, one content argument, or -content <text>; -TimeoutSec is no longer supported.' ;;
esac

case "$content" in
    *[![:space:]]*) ;;
    *) fail 'Markdown content must not be empty or whitespace-only.' ;;
esac

# Pass data as a quoted argument, never as executable PowerShell source.
# The updated script accepts -content only and does not consume stdin itself.
exec pwsh -NoLogo -NoProfile -NonInteractive -File "$script_path" -content "$content"
