---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: gpt-5.6-luna|openai
copilot-command-last-used: 1787081987463
---
## Task
Generate a high-signal, actionable summary from notes shown on the Obsidian Bases table in {activeNote}.
## Resources
- Notes shown on the Obsidian Bases table in {activeNote}
## Directives
- Extract the notes shown on the Obsidian Bases table in {activeNote}.
- Infer categories from note content and frontmatter (tags, paths, type, etc), if present.
## Requirements
- Output must:
	- ignore prior chat history or external context not included in the input.
	- group content by meaningful, inferred categories (e.g., Security, DevOps, AI, Infrastructure, Research, Ideas, Personal, etc.). 
	- group content must be structured as list where each list item starts with a note reference (wikilink) followed by related content.; A note can be referenced only once per group
	- contain only high-signal information: key facts, insights, notable commands/configs, risks, constraints, and actionable takeaways.
	- exclude fillers, repetition, trivial steps, and generic background.
	- use smart brevity: short sections, dense bullets, one idea per bullet, minimal narrative.
	- highlight operational details (commands, configs, warnings, best practices, architectural insights).
	- not fabricate missing categories, facts, or context.
- Priority: Signal density > Clarity > Brevity > Completeness.
## Failure & Clarification Rules
- Empty Obsidian Bases table ⟶ output: “No eligible notes found in the Journal.”
- Categories are ambiguous ⟶ infer the most likely based on content/tags and note the inference.
- Never invent facts or categories not present in the input.
- Conflicts arise ⟶ user-provided note content takes precedence.
## Success Criteria
Response:
- does not include preamble, closing remarks, or extra sections.
- covers all notes in the Obsidian Bases table
- does not contain any information that is not directly backed by notes on the Obsidian Bases table
- All notes used are cited as Wiki-links
## Deliverables
A smart brevity style Markdown report of the notes in the Obsidian Bases table on {activeNote} with:
1. “Quick Overview” section: one bullet per category, each stating the main insight.
2. Category headings (inferred from notes/tags/paths).
3. For each category: dense bullet summary of high-signal content with highlights of operational/practical details (max. 3 for each note in this category).
