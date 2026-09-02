---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 30
copilot-command-model-key: 500215dd-d41b-4618-9788-6b4e4bf7cb15
copilot-command-last-used: 1787647394415
---
## Task
Rewrite provided text as a Markdown fenced code block, properly formatted and labeled with the correct language tag

## Deliverables
1. Only one Markdown fenced code block with the detected language tag (or `undefined` if unclear)
2. If errors remain after re-formatting, list them as bullet list in an Obsidian callout (`> [!error]`) after the code block

## Requirements
- Follow the dominant style convention for the detected language (e.g., Prettier defaults for `js`/`ts`, `gofmt` for `go`); if none is identifiable, preserve the input's existing formatting
- Use lowercase canonical language tags (e.g. `js`, `ts`, `sh`); use `undefined` only when the language cannot be determined
- Normalize whitespace and indentation only as required for syntactic validity and readability.  
- Preserve all existing code logic, ordering, and structure
- If constraints conflict, preserve code logic and semantics over formatting and error reporting
- Do **not**:
	- rewrite, refactor, or alter code semantics
	- flag errors that were fixed by reformatting

## Contingencies
- Input is an incomplete fragment (missing braces, parentheses, or keywords) ⟶ format it as-is without adding or repairing tokens
- Input is empty ⟶ output an empty fenced code block
- Input is not recognizable as code ⟶ output unchanged wrapped in a fenced Markdown block
- Syntax cannot be verified or the programming language cannot be confidently determined ⟶ proceed with best-effort formatting
- Reformatted code still has syntax errors ⟶ list them in the error callout
