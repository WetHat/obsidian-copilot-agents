---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: ""
copilot-command-last-used: 0
---
## Task

Using current, read-only web research and the model inventory in [[Models]], determine for every listed LLM the single reasoning level best suited to the workloads defined in Context, then produce an evidence-backed ranking of all models evaluated at their selected optimum reasoning level. The task is complete when the response contains one justified row per model in [[Models]], the report is saved to `Inbox`, and completion is signaled per Deliverables.

## Context

- **Audience and purpose:** An Obsidian Copilot user selecting an assistant model for the OpenCode framework. The evaluation enables selecting optimal models for knowledge-management workloads, technical reasoning, coding, tool use, latency, and cost.
- **Environment:** OpenCode assistant AI running within Obsidian Copilot.
- **Timeframe:** Availability, capabilities, pricing, latency, and API behaviors are time-sensitive; report the research date explicitly.
- **Conversation memory:** All model identifiers are pinned in [[Models]]; do not rely on prior-turn conversational reasoning unless restated by the user. Turn details reset except for the saved evaluation note and ranking data.
- **Fact boundaries:**
	- **Fact:** Target runtime environment is OpenCode in Obsidian Copilot.
	- **Fact:** Models to evaluate must come strictly from [[Models]].
	- **Fact:** Models vary in reasoning controls: some have discrete levels, some continuous token budgets, some boolean on/off, and some no configurable reasoning.
	- **Inferred:** Best-level selection is workload-relative: the chosen level must maximize knowledge-work value across technical reasoning, coding, tool use, latency, and cost — not benchmark peaks alone.
	- **Unknown:** Whether every identifier in [[Models]] is currently active, a vendor alias, private deployment, or deprecated. Verification is mandatory; never substitute a similarly named model.

## Success Criteria

1. **Model coverage:** Every model identifier in [[Models]] appears verbatim in the Ranking Table with exactly one data row per model.
2. **Best reasoning-level determination:**
	- Discover available reasoning controls for each model via authoritative vendor documentation and API specifications.
	- Derive candidate levels per model: 1 candidate if the model has only 1 setting or no configurable reasoning (base/standard mode); 2 candidates if it has exactly 2 settings (e.g., off / on, min / max); 3 candidates spread evenly if it supports 3 or more discrete settings or a continuous token budget (e.g., minimum, midpoint, maximum; or low, medium, high).
	- Evaluate the candidate levels against the weighted dimensions in Criterion 3 and select exactly one best level per model: the candidate with the highest total weighted score; on a tie, the lower (cheaper / faster) level.
	- Report the selected level and a selection rationale stating why it outperforms the other candidates for the workloads.
3. **Scoring dimensions & weights:** Score each model at its selected best level from 0–100 using these exact weights:
	- Reasoning and problem solving: 25%
	- Coding and software-engineering capability: 20%
	- Tool use, agentic reliability, and instruction following: 20%
	- Context handling and adherence to complex instructions: 15%
	- Factuality, uncertainty handling, and self-correction: 10%
	- Practical efficiency for OpenCode (latency, cost, context window): 10%
4. **Rankability gate:**
	- A numeric score (0–100) is assigned only when model identity and the selected reasoning setting are directly verified, and at least 4 of the 6 weighted dimensions have supporting evidence from authoritative vendor docs or benchmark-maintainer sources.
	- Rows with fewer than 4 evidenced dimensions or unverified settings are marked `NR` ("Not Rankable") with missing evidence stated.
	- Scored rows appear first, sorted descending by score; `NR` rows follow without invented ordering. Ties are labeled `Tied`.
5. **Factuality & citations:**
	- Cross-check every factual claim against at least one authoritative source; if none exists, state that limitation explicitly.
	- Require direct Markdown links for factual claims; never fabricate citations, benchmark scores, or capabilities.
	- Unsupported dimensions are labeled `Unknown`.
6. **Persistence verification:** The complete report is saved to `Inbox/` strictly following the naming format and collision rules specified in Autonomy & Approval Boundaries, and the Save Status section reports the outcome.
7. **Priority order when criteria conflict:** Factual accuracy and non-fabrication → verbatim [[Models]] coverage → transparent uncertainty → best-level determination with documented per-model rationale → ranking usefulness → brevity.

## Deliverables

Output valid GitHub Flavored Markdown only, with no preamble, introductory greetings, or meta-commentary outside the sections below. Nothing appears outside these six sections.

### Recommendation

Up to three recommended model–reasoning configurations, each at its selected best reasoning level. Every recommendation must include its principal use case, main trade-off, confidence level, and authoritative citations.

### Research Scope and Method

State:
- Research date.
- Discovered reasoning parameters and best-level selection methodology: how candidate levels were derived across the supported range per model, and how the best level was chosen, including the tie rule.
- Source hierarchy (vendor documentation > benchmark maintainers > third-party analyses).
- Scoring weights and handling of missing, conflicting, or unverified data (`NR`, `Unknown`, explicit gap identification).

### Ranking Table

One table containing exactly one data row per model in [[Models]]:

| Rank | Model | Vendor | Discovered reasoning range | Selected best level | Selection rationale | Evidence status | Score / 100 | Confidence | Ranking rationale | OpenCode caveat | Sources |
| --- | --- | --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- |

Requirements:
- Sort numerically scored rows descending by score; place `NR` rows after scored rows.
- Use `Tied` where scores match.
- `Selection rationale` and `Ranking rationale` cells are ≤ 30 words each.
- Cite factual claims with direct Markdown links in relevant cells.
- Keep analyst inferences distinguishable from sourced facts.

### Limitations and Decision Guidance

List material selection caveats, including unverified identifiers, level selections constrained by incomplete comparison evidence, missing mode-specific benchmark data, latency/pricing tradeoffs, or OpenCode-specific integration limits.

### Save Status

Report exactly one of:
- `Saved to: [[Inbox/<filename>.md]]` after successfully writing the new Markdown note.
- `Save failed: <brief reason>` if the write failed or the file-writing tool was unavailable. Never claim success if the write did not succeed.

### Completion Status

End with:
`Evaluation complete. Further comparison criteria, weighting changes, or model updates can be requested.`

## Directives

1. Execute the evaluation to satisfy Success Criteria and produce the exact structure defined in Deliverables.
2. Follow this execution sequence: read [[Models]] → perform web research to verify model identifiers and discover reasoning parameters → derive candidate levels per Success Criteria Criterion 2 → gather evidence across the 6 dimensions for each candidate level → select the best level per model per the selection rules in Criterion 2 → score at the selected level → generate deliverables → save note to `Inbox` → output response.
3. Reasoning discovery rule: Never disqualify or mark a model `NR` solely because it lacks canonical `low`, `medium`, or `high` labels.
4. Tool economy: Use one broad discovery search followed by targeted retrievals for documented evidence gaps. Do not repeat substantially identical searches.
5. Self-check gate: Before emitting output, silently validate: exactly one row per [[Models]] entry; every scored row has a selected level with a selection rationale; citation URLs are valid Markdown links; table columns match the header schema; file persistence succeeded. Fix discrepancies internally; surface only unresolvable issues.
6. Multi-turn lifecycle: On turn 1, provide the full deliverable. If the user requests weighting, workload, or model adjustments, update the evaluation while preserving unaffected elements. If ambiguity arises, ask up to 2 clarifying questions per round while keeping the dialogue open.
7. Anti-fabrication: Do not invent benchmark results, pricing, availability, or reasoning controls.

## Failure & Clarification Rules

Apply rules in order; first matching rule wins. Priorities resolve per the priority order in Success Criteria.

1. Web access unavailable: If web research tools are completely unavailable, emit a deterministic failure report stating that research tools are offline and ranking cannot proceed without live evidence. Do not output conversational questions or partial ungrounded rankings.
2. Unverifiable model: If an identifier in [[Models]] cannot be verified in authoritative records, retain the model verbatim, record Discovered reasoning range as `Unknown`, Selected best level as `None`, Evidence status as `Unverified`, and Score as `NR`. Never substitute a similar model.
3. Insufficient evidence: If fewer than 4 of the 6 dimensions have authoritative evidence for the selected level, assign `NR`, identify the missing areas, and label unsupported dimensions `Unknown` — never fill gaps with plausible-sounding detail. If level-comparison evidence is incomplete but the model has multiple settings, select the level with the strongest available evidence and state this constraint in Selection rationale and Limitations.
4. Conflict resolution: If sources conflict, resolve strictly according to the priority order in Success Criteria. Document the discrepancy and preferred source under Research Scope and Method.
5. Clarification exclusivity: If blocking clarification is required, output ONLY the clarification request. If a partial ranking is feasible, provide it explicitly labeled `Partial` with missing evidence gaps enumerated.

## Autonomy & Approval Boundaries

- **Safe actions (permitted without prior confirmation):**
	- Read [[Models]] and referenced context notes.
	- Perform read-only web searches and fetch public documentation pages.
	- Create one new Markdown note in `Inbox/` matching `OpenCode ModelEvaluation - YYYY-MM-DD.md` (or suffixed `-02`, `-03` on collision).
- **Confirmation triggers (must pause and request user confirmation before proceeding):**
	- Overwriting any existing note.
	- Writing or creating files outside `Inbox/`.
	- Executing live model inference calls, using private API credentials, or incurring financial charges.
	- Modifying vault configuration or plugin settings.
- This section constitutes the sole approval policy; no approval language may appear in any other section.

## Resources

- `[[Models]]` (Dataset, Primary): The authoritative in-vault list of model identifiers to evaluate.
- Web Search & Retrieval Tools (Tool, Primary): Read-only web query and page fetch capability. Failure mode: report timeout/failure and proceed with verified context or trigger Failure Rules.
- Local Note Writer (Tool, Primary): File creation tool targeting `Inbox/`. Failure mode: report failure in `Save Status` and emit full report to output stream.
- Vendor & Benchmark References (Reference, Authoritative): Official vendor documentation, model cards, API specifications, LMSYS Chatbot Arena, SWE-bench, and OpenCode documentation.
