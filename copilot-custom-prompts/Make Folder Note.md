---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: 3e166e02-ba29-4d85-9205-0ebedac5fb78
copilot-command-last-used: 1790085430079
---
## Task

Analyze the README-type note identified by `{activeNote}` and its parent folder, then produce and insert an orientation callout that recommends only note types and subject matter whose content belongs in the folder. Each run has exactly one outcome: success, in which the note is updated and only the generated callout is returned; or failure/clarification, in which the note is unchanged and the issue is reported in chat. A later request is a new run and requires rereading the current note and evidence.

## Context

- **Locale/domain:** Obsidian vault; use Obsidian-flavored Markdown, wikilinks, and valid YAML frontmatter.
- **Authoritative inputs:** `{activeNote}`; its parent folder's direct child notes only (content and frontmatter); its parent folder's subfolder names; explicitly relevant sibling notes; available backlinks and tags; and [[Folders]].
- **Independent sources:** count a source as independent only when it is a distinct note or distinct structural reference, not a repeated excerpt, backlink, tag, or citation derived from the same note.
- **Fact:** `{activeNote}` is the folder's README/folder note. This identifies the task input but does not establish the folder's purpose or subject matter domain.
- **Inferred:** The folder's purpose, domain, note types, and content-inclusion rule must be derived from inspected evidence.
- **Unknown:** Anything not supported by that evidence. Do not fill gaps with plausible detail or infer note content from filenames or titles alone.

## Success Criteria

- The callout contains a summary of the inferred purpose and subject-matter domain (< 300 words), 3–5 evidence-based recommendations for note types or content, and one content-based decision rule answering: “What do I need to consider when deciding whether a note belongs here?”
- Every recommendation is actionable and specific to the content evidenced in the inspected notes; recommendations do not concern frontmatter, YAML, templates, naming, filing, or other organizational changes, except for domain-related tags. The required `headline`/`tags` upsert is an implementation action, not a recommendation.
- Existing note content and frontmatter remain unchanged except for the generated callout and requested `headline`/`tags` upserts. The evidence and preservation rules in this section are authoritative and are not repeated or reinterpreted elsewhere. Later turns reread the current note and relevant evidence.
- Factual claims are cross-checked against at least two independent authoritative vault sources whenever two are available and cite those sources with Obsidian wikilinks. Never fabricate citations. Evidence-supported inferences may be labeled `Inferred`; unsupported facts remain `Unknown`.

## Deliverables

The updated `{activeNote}` is the primary deliverable.

- **Success:** return exactly the generated callout block below, without a code fence, preamble, explanation, status line, or error text.
- **Failure or clarification:** return only the chat-only report required by Failure & Clarification Rules; do not return any callout.

Required callout shape:

> [!orientation]+
> {{summary of inferred purpose and subject matter domain, with citations for factual claims}}
>
> **Recommended Note Types & Content:**
> - {{Actionable recommendation for note type/content 1}}
> - {{Additional actionable note type/content recommendations when supported, up to 5 total}}
>
> **Decision rule:**
> - {{What to consider when deciding whether a note belongs in this folder}}

Replace every `{{...}}` slot with evidence-based content; never emit slot text. Keep the summary to no more than 3 sentences and each recommendation to one bullet. The returned callout is the completion signal; remain available for follow-up changes.

## Directives

1. Resolve `{activeNote}` and [[Folders]], then inspect its parent folder's, location, subfolders, direct child notes, relevant sibling content/frontmatter, backlinks, and tags. Do not descend into subfolders. Batch independent reads/searches when possible and do not repeat substantially identical searches.
2. Separate facts, inferences, and unknowns. Cross-check supported factual claims against the available authoritative sources and cite them with wikilinks. Keep analysis and reasoning out of the response.
3. Draft the required callout to satisfy Success Criteria and Deliverables; keep all chat-only failure content out of it.
4. Choose the edit target: if `{activeNote}` contains an `orientation` callout (case-insensitive, optional fold marker) whose body contains only blank lines, placeholder tokens, or boilerplate template labels and no substantive guidance, replace that complete callout block. Otherwise, insert the generated callout immediately after existing YAML frontmatter, or at the beginning when frontmatter is absent. Never replace a substantive orientation callout; preserve every other note element verbatim.
5. Apply `extract-headline` to the completed callout/analysis result and use its exact plain-text output as `headline`. Apply `extract-tags` to the same input with the default `tagLimit` unless another integer is supplied; convert its exact comma-separated output into the YAML `tags` list.
6. Upsert exactly one `headline` and one `tags` property, preserving all other frontmatter keys and values. Create frontmatter if absent and quote or escape the headline as needed for valid YAML.
7. Validate the final note, including edit target, preservation, callout syntax, citations, frontmatter validity, absence of duplicate keys, both skill outputs, and the Success Criteria. On success, return only the callout.

Apply these directives in order. When constraints conflict, preserve existing note content first, then valid Obsidian/YAML syntax, evidence and citation discipline, callout structure and recommendation scope, and finally wording brevity.

## Failure & Clarification Rules

Every rule in this section is chat-only: report the flagged item, error, or clarification request in the chat window; never put it in the callout or write it into `{activeNote}`. When a rule triggers, do not claim successful completion.

1. If `{activeNote}` or a required vault reference cannot be resolved, read, or edited, stop and ask no more than 2 targeted clarification questions in chat; make no note change.
2. If evidence is too incomplete or materially conflicting to support the required callout, report the limitation in chat and ask no more than 2 targeted questions when they can resolve it; make no note change.
3. If `extract-headline` or `extract-tags` is unavailable or fails, report the exact skill failure in chat; do not silently substitute another method and do not claim the corresponding property was generated.
4. If insertion, replacement, frontmatter upsert, or final validation fails, report the specific failed operation and the note's actual state in chat. Do not claim completion or emit the success callout.

## Autonomy & Approval Boundaries

- May read the named vault evidence, run non-destructive local checks, invoke `extract-headline` and `extract-tags`, and modify only `{activeNote}` for the requested callout and `headline`/`tags` operations.
- Any write to another file, destructive operation, external side effect, or material scope expansion requires confirmation before execution.

## Resources

- **Reference — primary:** `{activeNote}`, its parent folder, direct children, subfolders, and sibling notes — source of current note state and content evidence.
- **Reference — secondary:** [[Folders]], backlinks, and existing tags — corroborating structure and domain vocabulary.
- **Tool — vault read/search/edit:** inspect the listed evidence and update only `{activeNote}`; failures are handled in Failure & Clarification Rules.
- **Skill — `extract-headline`:** completed callout/analysis Markdown → one plain-text headline line.
- **Skill — `extract-tags`:** completed callout/analysis Markdown plus optional integer `tagLimit` → sorted comma-separated tag list.
