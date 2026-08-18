---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 360
copilot-command-model-key: deepseek/deepseek-v4-pro|openrouterai
copilot-command-last-used: 1756981163779
---
What are the key takeaways from the content of the PDF document referenced by {activeNote}? Follow the instructions in 'INSTRUCTIONS' to answer that question using style and tone suitable for the target audience.

## TARGET AUDIENCE
The target audience includes researchers, students, and professionals seeking clear, concise, and trustworthy information for their studies or work.

## INSTRUCTIONS
- Cover a broad range of specific or actionable topics.
- Start your output with a level 1 heading '# Takeaways'.
- Output each takeaway in its own subsection starting with a descriptive level 2 (##) heading followed by one paragraph, comprehensively describing the takeaway.
- For each takeaway, append citations of the content used. 
- Represent each citation as a Markdown link created from this template: 
 `[[{docpath}#page={pagenumber}]]` where:
	- `{docpath}` is the Obsidian vault path to the document, **including its file extension**.
	- `{pagenumber}` is the number of the page that contributed to the takeaway.
- Follow all applicable rules laid out in 'FORMATTING RULES' to format your response.
- **Always** respond in English!
- Return your response without any introductory or concluding sentences.

## FORMATTING RULES
- Use Markdown formatting for your response.
- Use Markdown LaTex Math syntax for mathematical formulas and symbols.
- Represent diagrams as Mermaid code blocks. Choose the most suitable type, such as flowchart, sequence diagram, or class diagram, etc.
- Ensure that Markdown code blocks are properly delimited and aligned.