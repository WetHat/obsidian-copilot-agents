---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 60
copilot-command-model-key: ae4a2a4f-a327-412f-b864-f8898ba4e774
copilot-command-last-used: 1787516909983
copilot-command-description: Enhance Obsidian note discoverability and utility by assigning relevant metadata tags
---
## Directives
1. Generate the requested number of tags tags for the content of the provided note using `extract-tags`
2. Merge these tags with any pre-existing tags
3. Deduplicate the combined tag list
4. Sort tags alphabetically (case insensitive)
5. upsert the `tags` frontmatter property of the provided note using the consolidated tags (using YAML array format)

## Contingencies
- Provided note content is empty or contains no discernible topics ⟶ Ask user to provide content to tag
- Not number of tags specified ⟶ use default
- Conflicting or malformed tags are encountered ⟶ normalize or omit as per the above rules.
- Ambiguity arises regarding tag selection ⟶ default to the most relevant and frequently used tags in the vault.