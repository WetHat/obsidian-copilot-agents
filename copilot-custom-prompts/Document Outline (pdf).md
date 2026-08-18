---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 300
copilot-command-model-key: deepseek/deepseek-v4-pro|openrouterai
copilot-command-last-used: 0
---
## INSTRUCTIONS
- Create a structured, indented table of contents for the content of the provided document.
- Represent each item in the table of contents as a Markdown heading (not list item) whose text is created from this template: 
 `{itemname} [[{docpath}#page={pagenumber}|p{pagenumber}]]` where:
	- `{docpath}` is the Obsidian vault path to the document, **including its file extension**.
	- `{pagenumber}` is the number of the page corresponding to the item. Both occurrences of the placeholder must be substituted.
	- `{itemname}` is the item name.
- Determine the heading level of each item based on the following hierarchy:
    - Top-level items (e.g., "About", "Contents") should be level 1 headings (#).
    - "Chapter" items should be level 2 headings (##).
    - "Section" items should be level 3 headings (###).
    - Any further sub-levels should increase the indentation accordingly.
- Do not include any introductory or concluding sentences.
- **Never*** wrap your response into a Markdown code block.