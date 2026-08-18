---
name: extract-tags
description: >-
  Extract unique, semantically central tags from Markdown input.
  Use when generating, or reviewing tags for notes; not for ordinary content editing.
metadata:
  copilot-enabled-agents: codex,opencode
---

# Extract Tags

## Output
One plain-text, comma-separated list of tags with no spaces or Markdown. Sort tags alphabetically, case-insensitive.

## Input
- Markdown text.
- `tagLimit` (integer, default 5): maximum number of tags to return; must be ≥ 1.

## Reference
- [[Note Type Definitions]]

## Requirements
- Tags must be semantically:
	- central to the content, not incidental.
	- orthogonal to types from Note Type Definitions
- Prefer existing vault tags; if equivalent tags fit, prefer the more frequent one.
- Use a new tag only if no established tag accurately represents a central topic.

## Contingency
- `tagLimit` omitted, non-integer, or < 1 → use the default.
- Empty, non-text, or tag-irrelevant input → return the single highest-frequency vault tag (ignore `tagLimit`).
- Ambiguous content → among candidate tags already in the vault, keep the highest-frequency one, up to `tagLimit`.
- If no vault tags exist or none can be discovered → generate new tags from the content alone.

## Example
- Request: "Extract 2 tags from this Markdown about AI and content analysis."
- Output: `ArtificialIntelligence,ContentAnalysis` 