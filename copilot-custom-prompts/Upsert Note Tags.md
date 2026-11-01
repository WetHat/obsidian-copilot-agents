---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: ae4a2a4f-a327-412f-b864-f8898ba4e774
copilot-command-last-used: 1793538808879
---
## Target

`{activeNote}` is either a Markdown note or an Obsidian Canvas (`.canvas`).

## Content

- **Markdown** — use the note body as provided.
- **Canvas** — invoke the `canvas-content` skill on the active file and use its output.

## Task

1. Call the `extract-tags` skill on the resolved content.
2. Read the existing tags from the raw file using the `property:get` from `obsidian-cli` — and merge them with the extracted tags.
3. Deduplicate, sort case-insensitively, and normalize to PascalCase.
4. Use the `canvas-frontmatter` skill for canvas files or `property:set` from `obsidian-cli` set `tags` as a list property on the active file.
5. Report the path and the final list. If the file is a canvas, note that its properties may not appear in the Properties pane until the canvas is reopened.

## Contingencies

- Provided content is empty or contains no discernible topics ⟶ ask the user for content to tag.
- Number of tags is not specified ⟶ use the default.
- Tags are malformed or conflict with vault conventions ⟶ normalize them.
- Tag selection is ambiguous ⟶ prefer the most relevant and frequently used tags in the vault.
