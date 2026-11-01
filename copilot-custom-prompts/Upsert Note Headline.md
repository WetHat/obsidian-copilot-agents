---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 10
copilot-command-model-key: ae4a2a4f-a327-412f-b864-f8898ba4e774
copilot-command-last-used: 1793538862122
---
## Target

`{activeNote}` is either a Markdown note or an Obsidian Canvas (`.canvas`).

## Content resolution

- **Markdown** — use the note body as provided.
- **Canvas** — the file is JSON. Build the content using `canvas-content` skill
## Task

1. Call the `extract-headline` skill on the resolved content.
2. Write the result with `obsidian-cli`.
3. Report the path and the written value. Canvas properties may not appear in the Properties pane until the canvas is reopened.
## Constraints

- Use the active file's vault-relative path from the context envelope.
