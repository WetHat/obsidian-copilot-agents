---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 340
copilot-command-model-key: deepseek/deepseek-v4-pro|openrouterai
copilot-command-last-used: 1759002031333
---
## INSTRUCTIONS
- For the content of the PDF document provided by the context, create a structured, indented table of contents .
- Use markdown formatting for your response.
- Represent each item in the table of contents as a Markdown link created from this template: 
 `{level} {itemname} [[{docpath}#page={pagenumber}|p{pagenumber}]]`, where:
	- `{docpath}` is the Obsidian vault path to the document, **including its file extension**.
	- `{pagenumber}` is the page number where item is located.
	- `{itemname}` is the name of the item.
	- `{level}` Represents a sequence of Markdown heading characters (#) corresponding to the item's hierarchy level. Default is level 1 (#).
- Determine the heading level of each item based on the following hierarchy:
    - Top-level items (e.g., "About", "Contents") should be level 1 headings (#).
    - "Chapter" items should be level 2 headings (##).
    - "Section" items should be level 3 headings (###).
    - For any further sub-items, continue increasing the heading levels as needed.
- Return **exclusively** the table of contents without adding any introductory or concluding sentences.
- **Never*** wrap your response into a Markdown code block.