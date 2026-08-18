---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 320
copilot-command-model-key: deepseek/deepseek-v4-pro|openrouterai
copilot-command-last-used: 0
---
## INSTRUCTIONS
1. Thoroughly analyze and interpret the Mermaid node below 'INPUT' given in the format `NAME[concept]` or `NAME(concept)`and extract its `NAME` and `concept` strings.
2. Find notes @vault related to `concept`. Use these notes to accurately and thoroughly fill out the response template defined below `RESPONSE TEMPLATE`(follow the template instructions).
3. Output a list of notes you considered as candidates for reference.
4. Finally return  the completed response template.

## RESPONSE TEMPLATE
~~~
	{NAME} -.->|covered by| FN_{NAME}("{note}")
	class FN_{NAME} footnote;
	class FN_{NAME} internal-link;
~~~

**Template Placeholder Definitions**:
1. `{NAME}`: The name of the Mermaid diagram node as given below `INPUT`.
2. `{note}`: The filename of the most relevant note you found earlier. Ensure the note physically exists in the Obsidian vault. If you did not find such a note, do not hallucinate one, give up and say so. Omit the note link delimiters (`[[`) and (`]]`).

## INPUT
{}