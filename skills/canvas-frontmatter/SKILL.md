---
name: canvas-frontmatter
description: >-
  Read, set, merge, and remove properties in Obsidian Canvas frontmatter
  (`metadata.frontmatter`); not for editing nodes, edges, layout, or Markdown note frontmatter.
metadata:
  copilot-enabled-agents: opencode
---

# Canvas Frontmatter

## Requirements

- The `obsidian-cli` skill
- Canvas Enhance installed with `canvasMetadataCompatibilityEnabled` on (enabled in this vault).
- The active file's vault-relative path.

## Read

- **Canvas** — read the raw JSON and use `metadata.frontmatter`. Do not use `property:read` for a merge; it may return nothing after a previous write.
- **Markdown** — read YAML frontmatter from the raw file.
- `property:read` is safe only on a freshly indexed file and for scalar values; it does not return array values reliably.
- Read once, before any write in the run. Merge in memory.

## Set

One property per `property:set` call, targeting the canvas file by `path` and property by name, value and type; `type` is one of `text`, `list`, `number`, `checkbox`, `date`, `datetime`:
- List values are comma-separated; do not put a comma inside a list item.
- Preserve every property not named in the request.
- For arrays, read the existing values, append, deduplicate, sort case-insensitively, then set once.

## Remove

One property per `property:remove` call, targeting the canvas file by `path` and property by name

## Initialise a canvas

`property:set` does not create a missing `metadata.frontmatter`. If the canvas has no `metadata` object, add this before the CLI call:

```json
"metadata": { "version": "1.0-1.0", "frontmatter": {} }
```

Preserve an existing `version`.

## Verify

- Re-read the raw file; confirm the property and that `nodes` and `edges` are intact.
- Do not use `property:read` immediately after a write.
- Canvas metadata may not appear in the Properties pane or Bases until the canvas is reopened. Report that rather than retrying.

## Contingencies

- CLI missing or the probe fails → stop and report; do not fall back to rewriting JSON by hand.
- `property:set` reports success but the raw file is unchanged → the canvas likely lacked `metadata.frontmatter` or was not indexed; initialise it, reopen the canvas, and retry once.
- Value contains a newline → replace it with a space; never emit YAML.
- Concurrent edits or a sync conflict → serialise writes; never write the same canvas twice in parallel.
