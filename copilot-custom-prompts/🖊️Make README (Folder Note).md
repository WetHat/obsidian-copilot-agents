---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 260
copilot-command-model-key: gpt-5.6-terra|openai
copilot-command-last-used: 1786980411491
---
## Task
Analyze a README-type note for a given folder and, by referencing related notes and content across the vault, determine the folder’s intended purpose. Based on your findings, provide actionable advice on how to use this folder effectively, including recommendations for what types of content or notes should be added to maximize its value.

## Resources
- [[Folders]] (vault structure)
- Folder containing README
- {activeNote} (README file)

## Context
- The README note is located at the root of a the its parent folder and is intended to describe or introduce the folder’s role.
- The vault may contain related notes, backlinks, or tags that provide additional context.
- Vault structure, note naming conventions, and existing content may all be relevant to the analysis

## Requirements:
- Accurately infer the folder’s purpose by synthesizing information from {activeNote} (README note)  and location the vault folder structure.
- Deliver a concise description of its purpose and clear, concise, practical guidance for organizing and populating the folder.
- Answer the question: "What do I need to when deciding if note goes here?"
- Ensure advice is actionable and tailored to the vault's structure.
- Do not output intermediary results or reasoning steps.
- Use clear, technical yet approachable language.

## Deliverables
An Obsidian callout block  containing:
	- A concise summary of the folder’s inferred purpose.
	- Specific, actionable recommendations for content to add or organizational strategies to employ.

Output Format:
~~~
> [!orientation]+
> This folder is {{summary of inferred purpose}}
>
> **Recommended Content & Usage:**
> - {{Actionable recommendation 1}}
> - {{etc.}}
~~~

## Contingencies
- README note is missing or empty ⟶ state this in the callout ask user to provide one
- Conflicting information is found ⟶ note the ambiguity and recommend clarification steps.
- Folder’s purpose is ambiguous -> state this and suggest general best practices for folder organization in Obsidian

## Directives
1. Analyze the README provided by {activeNote} and its location within the vault structure
2. Work step-by-step through the folder's context, related notes, and vault structure to ensure your final output is accurate, clear, and concise
3. Present your response per the _Output Format_ (without wrappers)
4. Before finalizing, verify that your summary and recommendations are directly supported by evidence from the README note and folder context