---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 50
copilot-command-model-key: gpt-5.6-luna|openai
copilot-command-last-used: 1788327659083
---
## Task
Generate a high-signal, actionable summary from the input notes.

## Resources
- Input: notes shown on the Obsidian Bases table in {activeNote}

## Directives
- Extract the input notes.
- Infer categories from note content and frontmatter (tags, paths, type, etc), if present.

## Deliverables
A smart brevity style Markdown report of the input notes with:
1. “Quick Overview” section: one bullet per category, each stating the main insight.
2. Category headings (inferred from notes/tags/paths).
3. For each category: Structured summaries.

## Requirements
- Output must:
	- ignore prior chat history or external context not included in the input.
	- group content by meaningful, inferred categories (e.g., Security, DevOps, AI, Infrastructure, Research, Ideas, Personal, etc.)
	- structure group content as a numbered list; each list item starts with a note reference (wikilink) followed by an indented bullet list (max. 3 items) of high-density operational/practical detail for that note
	- reference a note only once per group
	- contain only high-signal information: key facts, insights, notable commands/configs, risks, constraints, and actionable takeaways.
	- exclude fillers, repetition, trivial steps, and generic background.
	- use smart brevity: short sections, dense bullets, one idea per bullet, minimal narrative.
- highlight operational details (commands, configs, warnings, best practices, architectural insights).
 - Priority: Signal density > Clarity > Brevity > Completeness.

## Failure & Clarification Rules
- Empty Obsidian Bases table ⟶ output: “No eligible notes found in the Journal.”
- Categories are ambiguous ⟶ infer the most likely based on content/tags and note the inference.
- Never invent facts or categories not present in the input.
- Conflicts arise ⟶ user-provided note content takes precedence.

## Autonomy
- Read-only operation: do not modify, create, or delete any note or file; the Markdown report in the response is the only output.
