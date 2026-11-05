---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 420
copilot-command-model-key: ""
copilot-command-last-used: 1793623177730
---
## Target

`{activeNote}` is either a Markdown note or an Obsidian Canvas (`.canvas`).

## Content

- **Markdown** — use the note body as provided.
- **Canvas** — invoke the `canvas-content` skill on the active file and use its output.

## Task

- Invoke `infer_content_type` with the resolved content and use the `content_type.choice` property of the returned JSON object.
- For **Canvas** — Use the `canvas-frontmatter` skill to set `type` as a text property on the active file.
- For **Markdown** — use the `property:set`  from the  `obsidian-cli` skill

## Report

- Output the `content_type.choice` and `content_type.confidence`
- The file as wiki-link. If the file is a canvas, note that its properties may not appear in the Properties pane until the canvas is reopened.
