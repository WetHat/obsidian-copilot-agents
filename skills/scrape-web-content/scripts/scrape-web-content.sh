#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"
FORMAT="${2:-markdown}"
TIMEOUT_SEC="${3:-60}"

if [ -z "$URL" ]; then
  echo "Usage: scrape-web-content.sh <url> [markdown|json] [timeoutSec]" >&2
  exit 1
fi

case "$FORMAT" in
  markdown|json) ;;
  *) echo "Error: format must be markdown or json." >&2; exit 1 ;;
esac

if ! [[ "$TIMEOUT_SEC" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: timeoutSec must be a positive integer." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If PowerShell Core (pwsh) is available, use the canonical PowerShell script
if command -v pwsh >/dev/null 2>&1 && [ -f "$SCRIPT_DIR/scripts/scrape-web-content.ps1" ]; then
  exec pwsh -NoProfile -File "$SCRIPT_DIR/scripts/scrape-web-content.ps1" -Url "$URL" -Format "$FORMAT" -TimeoutSec "$TIMEOUT_SEC"
fi

# Fallback: curl + direct REST execution
: "${WINDMILL_SCRAPE_URL:?Error: WINDMILL_SCRAPE_URL is not set.}"
: "${WINDMILL_SCRAPE_TOKEN:?Error: WINDMILL_SCRAPE_TOKEN is not set.}"

if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is required to build and validate the Windmill payload." >&2
  exit 1
fi

PAYLOAD=$(node -e 'process.stdout.write(JSON.stringify({url: process.argv[1]}))' "$URL")
if ! RESPONSE=$(curl -s -f -X POST "$WINDMILL_SCRAPE_URL" \
  --max-time "$TIMEOUT_SEC" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $WINDMILL_SCRAPE_TOKEN" \
  -d "$PAYLOAD"); then
  echo "Error: Windmill request failed." >&2
  exit 1
fi

if [ -z "$RESPONSE" ]; then
  echo "Error: Windmill returned an empty response." >&2
  exit 1
fi

if ! node -e '
  try {
    const res = JSON.parse(process.argv[1]);
    if (!res || typeof res !== "object" || Array.isArray(res)) throw new Error("response must be a JSON object");
    if (typeof res.ttr !== "number" || !Number.isFinite(res.ttr)) throw new Error("ttr must be a number");
    if (typeof res.source !== "string" || !res.source.trim()) throw new Error("source must be a non-empty string");
    if (typeof res.article !== "string") throw new Error("article must be a string");
    if (!res.frontmatter || typeof res.frontmatter !== "object" || Array.isArray(res.frontmatter)) throw new Error("frontmatter must be an object");
  } catch (error) {
    console.error("Invalid Windmill response schema: " + error.message);
    process.exit(1);
  }
' "$RESPONSE"; then
  exit 1
fi

if [ "$FORMAT" = "json" ]; then
  echo "$RESPONSE"
  exit 0
fi

if command -v node >/dev/null 2>&1; then
  node -e "
    const res = JSON.parse(process.argv[1]);
    const fm = res.frontmatter || {};
    console.log('---');
    console.log('type: ' + (fm.type || 'capture'));
    console.log('link: \"' + (res.source || '') + '\"');
    console.log('reading_time: ' + (res.ttr || 0));
    console.log('authors: ' + JSON.stringify(fm.authors || (fm.author ? [fm.author] : [])));
    console.log('site: \"' + (fm.site || '') + '\"');
    console.log('keywords: ' + JSON.stringify(fm.keywords || []));
    if (fm.published) console.log('published: ' + fm.published);
    if (fm.publisher) console.log('publisher: \"' + fm.publisher + '\"');
    if (fm.expires) console.log('expires: ' + fm.expires);
    console.log('---');
    console.log('> [!info]+ ' + (fm.title || ''));
    if (fm.image) console.log('> ![image|float:right|200](' + fm.image + ')');
    if (fm.description) console.log('> ' + fm.description);
    console.log('');
    console.log(res.article || '_No article body extracted._');
  " "$RESPONSE"
  exit 0
fi

echo "$RESPONSE"
