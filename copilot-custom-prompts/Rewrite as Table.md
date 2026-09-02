---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 40
copilot-command-model-key: c2ab6ebf-f948-4be8-b412-a235b82ba651
copilot-command-last-used: 1786642321580
---
## Task
- Transform the provided content into a single Markdown pipe table with exactly one header row, a delimiter row following it, and the same number of columns in every row

## Instructions
1. Assess whether the content provided by {} is list-like, tabular, or otherwise structured; if it is not, output the Edge Case error table instead of transforming it.
2. **Headers**:
	- If headers are present, preserve them.
	- If headers are missing but a field name or pattern recurs at the same position in at least two items, infer headers from that repeated pattern
	- If no pattern recurs at the same position, or the repeated pattern is inconsistent, use generic headers such as `Col 1`, `Col 2`, etc.

## Deliverables
- Output only the raw Markdown pipe table, without additional text or explanation.
- Do not ask clarifying questions or request additional input; run the transformation or the Edge Case fallback.

## Requirements
- Output must be a valid GitHub Flavored Markdown pipe table
- Do not add any data that is not present in the input
- Preserve all data from the input in the output table, with no omissions
- Escape literal pipe characters in cell content as `\|` and collapse line breaks into HTML breaks `<br>` so each row stays on one line
- If constraints conflict, prioritize in this order:
	1. valid GFM table structure
	2. preserving all input data
	3. descriptive headers.
- Use the Edge Case error table only when the data cannot be represented in a valid table.

## Edge Cases
- Input is unstructured, partially structured, or cannot be meaningfully represented as a Markdown pipe table (e.g., code snippets, freeform text) → output a table with a single header cell `Error` and a single data cell
- The `Error` cell must contain exactly one sentence stating why the input cannot be rendered as a table; no apologies or extra explanation