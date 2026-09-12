#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"
FORMAT="${2:-markdown}"

if [ -z "$URL" ]; then
  echo "Usage: scrape-web-content.sh <url> [markdown|json]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If PowerShell Core (pwsh) is available, use the canonical PowerShell script
if command -v pwsh >/dev/null 2>&1 && [ -f "$SCRIPT_DIR/scripts/scrape-web-content.ps1" ]; then
  exec pwsh -NoProfile -File "$SCRIPT_DIR/scripts/scrape-web-content.ps1" -Url "$URL" -Format "$FORMAT"
fi

# Fallback: curl + direct REST execution
WINDMILL_URL="${WINDMILL_URL:-http://localhost/api/w/obsidian/jobs/run_wait_result/f/u/peterernst/scrape_markdown_article}"
WINDMILL_TOKEN="${WINDMILL_TOKEN:-lpWu39p3xrbGCT09CpdMRgnO2c4IDLIu}"

PAYLOAD=$(printf '{"url":"%s"}' "$URL")
RESPONSE=$(curl -s -f -X POST "$WINDMILL_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $WINDMILL_TOKEN" \
  -d "$PAYLOAD" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Failed to fetch from Windmill endpoint at $WINDMILL_URL" >&2
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
