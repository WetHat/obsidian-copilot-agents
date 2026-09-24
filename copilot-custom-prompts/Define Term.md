---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 410
copilot-command-model-key: ""
copilot-command-last-used: 1790061250030
---
## Task

Define exactly one term or acronym per turn, selected by `{}`, for readers of `{activeNote}`.  Make exactly two edits: append one unique footnote marker after the selection and one cited footnote paragraph at the note's end. Done means only those edits are made, the chat reports the result, and a later one-term turn remains available.

## Context

- Scope: the active Obsidian note; the purpose is to make the selected term understandable as used there.
- Inputs: `{}` — the current turn's selected text, trimmed; preserve it exactly. `{activeNote}` — full note and authority for local sense, language, register, tone, and style, but not external facts. The current user message supplies an explicit detail mode, if any.
- Boundaries: **Fact** = provided inputs and verified claims; **Inferred** = contextual sense and style; **Unknown** = unverified claims.

## Requirements

- Priority order for conflicts: one-term-per-turn and exact two-edit integrity, plus preservation of other note content > factual accuracy and source verification > correct context-specific sense > requested detail mode > brevity.
- Mode: Use `standard` unless the user explicitly requests `comprehensive`.
- Multi-turn state: a session may contain successive one-term definition turns. Pin `{activeNote}` and the established mode for the session; do not reread `{activeNote}`. Reset term-specific sense and research state for each new term. Change mode only on explicit request.
- Turn isolation:
	- process only the current term or acronym in the current turn.
	- a later turn is a new one-term transaction using the pinned note and carried-forward mode
	- never batch or silently defer additional terms
	- Tool/skill output is turn-local
- Source priority: search relevant vault notes first. If a matching definition is present in another vault note, use it as the primary definition and verify it against at least one external authoritative source; if no matching vault definition exists, use at least one external authoritative source as primary.
- Citations: cite 2–3 distinct sources, including at least one external source. Cite each referenced vault definition as its verified wikilink [[Vault Note Title]] and each external source as a titled Markdown web link [Source Title](URL). Within the footnote citation list, cite each source once; repeat the same ordered list once in the chat without adding duplicate entries.
- Failure and clarification turns use only the applicable failure path: no edits, successful-turn lines, preamble, task restatement, generic advice, reassurance, or padding.
### Note Requirements

- **Edit A:** first verify that the insertion point is outside code spans or blocks, link destinations or labels, existing footnote definitions, and raw HTML; then append exactly one `[^xxxx]` immediately after the selection. `xxxx` is four lowercase alphanumeric characters unique among the note's footnotes. Change nothing else there.
- **Edit B:** append exactly one final, single-paragraph footnote: `[^xxxx]: <definition>`, hard line break (2 trailing spaces), `<citations, 🔹-separated inline list>`. Use inline formatting and hard line breaks only. 
- Preserve all other content, formatting, links, footnotes, and whitespace. If either insertion point is unsafe or either edit cannot be applied and verified transactionally, revert any partial edit and leave no note change. Note, inserted content, and chat output must be valid Obsidian flavored Markdown.

### Definition Requirements

- Choose the most relevant sense; if one dominant sense remains with limited context, use it and label the assumption; otherwise clarify before editing. Match the note's language, register, tone, style, and voice; spell out acronyms unless established usage makes that unnecessary.
- `standard` = definition, purpose, and typical usage; `comprehensive` also includes supported logic, considerations, examples, and related terms.

## Deliverables

On success, produce exactly these three outputs in order, with no code fence or surrounding prose. If the fallback is used, append `; assumption: most common definition` to the Sense line; otherwise omit that suffix.

1. **Edit A** — at the selection: the selected text with `[^xxxx]` appended, and no other change at that location.
2. **Edit B** — at the end of the note: the single footnote definition line required by `Note Requirements`.
3. **Chat response** — exactly this completed template without fences:
   ```
   - Term: <term> — Sense: <chosen sense>
   - Marker: [^<xxxx>]
   - Detail mode: <standard|comprehensive>
   - Sources: <the same 2–3 citations, in the same order as the footnote>
   - Confidence: <0–100% definition correctness>
   - Notes: <assumptions, source limitations, or tool-failure fallbacks; omit this line when empty>
   - Done — available for the next one-term turn.
   ```

## Directives

1. Validate `{}` as one non-empty, recognizable term, multiword term phrase, or acronym. A multiword phrase is valid when it denotes one concept; multiple independently definable terms, lists, or batch requests in one turn are invalid.
2. Use the pinned `{activeNote}` before researching. Use the selection, nearby prose, headings, and subject to identify candidate senses; do not infer the sense from the term alone.
3. Apply the source-priority, verification, and citation rules defined in `Requirements`; do not restate them here.
4. Research economically: use `miyo-search` first to find local context and relevant vault-note definitions. Use a matching vault definition first, then fetch at least one external authoritative source to verify it. If no matching vault definition exists, fetch at least one external authoritative source and use it as primary. Stop when these requirements are met.
5. Inspect existing footnote identifiers, then execute the transaction specified in `Note Requirements` and `Definition Requirements`; do not duplicate their edit rules here.
6. On a later turns, validate the current selection against the pinned note and carried-forward mode; for changes or undo, verify the prior state explicitly identified by the user. Do not pre-empt future turns or process an implicit queue.

## Failure & Clarification Rules

Apply the first matching rule:

1. Empty, unrecognized, or out-of-scope selection → no edits; reply exactly: `Definition not found.`
2. Multiple independent terms, a list, or a batch request in one turn → no edits; ask exactly: `Which one term should I define this turn?`
3. Fewer than one independent authoritative external source, unverifiable citations, or unresolved conflict → no edits; reply exactly: `Definition not verified — authoritative cross-check unavailable.`
4. Multiple plausible senses remain → no edits; ask no more than 2 targeted questions and output only those questions.
5. A tool or source fails → report the failure and fallback only if source requirements remain satisfied; otherwise use Rule 3. Never lower the verification standard silently.
6. Unsafe or non-transactional edit location → no edits; reply exactly: `Definition not applied — selection is not safely footnoteable.`
7. If a bounded partial answer is more useful, provide only verified facts labeled `Partial:` without editing. Never fill gaps with plausible detail; label unknowns and confidence.

## Autonomy & Approval Boundaries

- Safe: read `{activeNote}` and relevant vault notes, use listed read-only resources, and make exactly the two defined edits to `{activeNote}` after requirements are satisfied.
- External research may transmit only `{}` and the minimum non-sensitive context required to identify the domain. Never transmit `{activeNote}`, personal data, secrets, or unrelated excerpts without confirmation.
- Confirmation is required for any other write, including creating, deleting, restructuring, or modifying another note; vault-wide actions; external requests that disclose protected context; external side effects; or material scope expansion.
- Multiple terms, vault-wide requests, and unrelated transformations are out of scope; offer only the one-term workflow instead.

## Resources

- **Tools — `miyo-search`, `read`, `grep`, `glob`:** find local usage and inspect actual contents; if Miyo is unavailable, use one non-redundant file search and report the fallback. Use file tools, not shell, for note operations.
- **References — relevant vault-note definitions:** first-priority sources for contextual meaning and wording. Official documentation, standards, primary or specialist sources are external authorities for factual verification. Wikipedia is secondary and never sufficient alone; use `docker-mcp_query-wolfram-alpha` for math/science when relevant.
- **Tool — Firecrawl `firecrawl_search`/`firecrawl_scrape`:** discovery → candidate URLs; scrape → source content. Cite only fetched pages, never snippets.
