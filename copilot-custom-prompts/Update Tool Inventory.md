---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 440
copilot-command-model-key: ""
copilot-command-last-used: 1792911771755
---
Read applicable instructions, then generate `tool-inventory-source-mapping` as a JSON object and always save it to `Vault Backoffice/Context Data/Tool and Skill Inventory.json`.

1. **Discover:** Enumerate parent-context tools, execution helpers, listed skills, and all currently configured catalog tools, exhausting pagination. In Code Mode, use `search` inside `functions.execute`. Do not enable servers/profiles, run operational tools, load every skill, or browse the web. Listed availability does not verify authentication, connectivity, or licensing.
2. **Source:** Build a name→description mapping from complete current tool definitions, catalog records, and skill metadata—not abbreviated listings, signatures, inferred text, or stale inventory. Preserve entire descriptions verbatim, including examples, restrictions, output contracts, and trailing instructions. Supply parent metadata when delegating; a subagent's narrower context is not evidence of parent unavailability.
3. **JSON:** Use a single JSON object mapping names directly to complete description strings. Retain exact callable paths, namespaces, separate aliases, `skill: <id>`, and helper labels except  `Code Mode: search` and `Code Mode: fetch`. Display names do not replace exact callable paths. Preserve descriptions verbatim, including generated Windmill wrappers, internal backticks, blank lines, and trailing instructions. Use standard JSON escaping so decoded strings match their sources; do not apply HTML escaping or readability transformations. Use `null` for unavailable descriptions and report those names separately. Do not wrap the mapping in another object or include commentary inside the JSON.
4. **Write:** Always write the mapping directly to `Vault Backoffice/Context Data/Tool and Skill Inventory.json`, replacing that file if it exists. Use reviewable file edits; if permitted mechanical regeneration uses a script, list the changed file. Do not modify any other file.
5. **Verify:** Re-read the saved JSON and verify that it parses. Compare category counts, unique names, and every decoded description against the source mapping verbatim, including Windmill descriptions. Inspect multiline endings, positive/negative score fields, answer-entry fields, and trailing instructions. Verify retained unverified entries separately against the previous destination. Report success only after verification; briefly identify the saved file and disclose unavailable descriptions, discovery gaps, and verification limitations. Listed availability does not verify authentication, connectivity, or licensing.
