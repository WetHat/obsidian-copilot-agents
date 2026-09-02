---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 60
copilot-command-model-key: 4e3732f9-bf6f-4ee0-888e-6b9d6d3440f5
copilot-command-last-used: 1787677436806
---
Present reasons to read a article based on content value and create a sharing link for Flipboard.

## Requirements
- The explanation must:
	- be plain text ≤ 500 characters
	- summarize why the content is useful, focusing on specific benefits
	- use clear, warm, casual, and  human-like language without promotional terms (e.g., no phrases like 'must-read', 'essential', 'life-changing')
	- not repeat the note title
- Do not include any additional commentary, headings, or extraneous text.

## Context
- An Obsidian note with a `link` property.
- The output is intended for sharing or embedding in other platforms.

## Directives
1. Analyze {activeNote} to determine why it is worth reading (the Reading Value)
## Contingencies
- `link` property is missing or empty ⟶ output an error message in a Markdown blockquote and halt further output.
- Note content is empty, output "No content available" as _Reading Value_. Then, output the _Flip It_ link as specified.
- `link` property is not a valid URL ⟶ output an error message in a Markdown blockquote and halt

## Deliverables
- Reading Value: Markdown fenced code block (language: markdown) containing the plain text explanation why the page is worth reading
- Flip It: `[Ⓕlip: {{page title}}](https://share.flipboard.com/bookmarklet/popout?v=2&url={{url encoded link property value}})`

## Example
```
~~~markdown
A summary the key findings from the latest project sprint with actionable insights for team improvement.
~~~
[Flip: Project Sprint Summary](https://share.flipboard.com/bookmarklet/popout?v=2&url=https%3A%2F%2Fobsidian.md%2Fnote%2F12345)
```