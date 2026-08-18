---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 60
copilot-command-model-key: c2ab6ebf-f948-4be8-b412-a235b82ba651
copilot-command-last-used: 1787038325273
---
## Task
Enhance the discoverability and utility of Obsidian notes by assigning relevant metadata tags. Your expertise includes analyzing technical, personal, or mixed-content notes to generate concise, accurate, and standardized tags.

## Context
- Notes may contain technical, personal, or mixed content.

### Resources
- {[[AGENTS.md]]}

### Skills
- {[[copilot/skills/extract-tags/SKILL|extract-tags]]}

## Deliverables
- A frontmatter array property formatted as: `tags: [ {{tags}} ]`

## Requirements
Tags must strictly follow the AGENTS directives.

## Directives
1. Generate tags for {activeNote} using skill `extract-tags`
2. Merge these tags with any pre-existing tags
3. Deduplicate the combined tag list
4. Sort tags alphabetically (case insensitive)

## Contingencies
- Provided note content is empty or contains no discernible topics ⟶ output `tags: []`.
- Conflicting or malformed tags are encountered ⟶ normalize or omit as per the above rules.
- Ambiguity arises regarding tag selection ⟶ default to the most relevant and frequently used tags in the vault.