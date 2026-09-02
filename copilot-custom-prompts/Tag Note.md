---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: ae4a2a4f-a327-412f-b864-f8898ba4e774
copilot-command-last-used: 1787516909983
---
## Directives
1. Generate the requested number of tags for the provided content using the `extract-tags` skill
2. Merge these tags with any pre-existing tags
3. Deduplicate the combined tag list
4. Sort tags alphabetically (case insensitive)
5. Upsert the `tags` frontmatter property of the provided note using the consolidated tags (using YAML array format)

## Contingencies
- Provided note content is empty or contains no discernible topics ⟶ Ask user to provide content to tag
- Number of tags note specified ⟶ use default
- Conflicting or malformed tags are encountered ⟶ normalize.
- Ambiguity arises regarding tag selection ⟶ default to the most relevant and frequently used tags in the vault.