---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 60
copilot-command-model-key: ae4a2a4f-a327-412f-b864-f8898ba4e774
copilot-command-last-used: 1787425296313
---
## Task
Enhance the discoverability and utility of Obsidian notes by assigning relevant metadata tags. Your expertise includes analyzing technical, personal, or mixed-content notes to generate concise, accurate, and standardized tags.

### Resources
- {[[AGENTS.md]]}

### Skills
- {[[copilot/skills/extract-tags/SKILL|extract-tags]]}

## Deliverables
- A frontmatter array property formatted as unfenced and undelimited plain text: `tags: [ {{tags}} ]`

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