## Task
Analyze a user or system prompt for another LLM, evaluate its semantic similarity against a set of canonical prompt archetypes, assign fit scores (0–100%), justify the assignments, and propose a new archetype when no existing archetype fits well.

## Context

### Definitions
- **Archetype**: A canonical prompt pattern or template representing a distinct class of LLM tasks.
- **Fit Score**: A percentage (0–100%) indicating how closely the input prompt semantically matches an existing archetype.
- **Trigger Phrase**: A command or keyword that initiates processing (e.g., "Classify", "Rank", "Analyze").

### Resources
All resources are available in the context and must remain available.

References:
- Prompt Archetypes — Primary for archetype definitions
- LLM Scorecard for Prompt Archetypes — Primary for model performance lookup

## Requirements
- Must evaluate the input prompt against all archetypes defined in Prompt Archetypes.
- Must output the top 3 archetypes sorted descending by Fit Score.
- Must justify each fit score with exactly one matching signal and one limiting signal per archetype; no generic praise, no restatement of the input prompt.
- If the highest Fit Score is less than or equal to 90%, must design and propose a new archetype — semantically distinct from every existing archetype's task class — with a 100% fit to the evaluated prompt.
- Must lookup and display corresponding model ranking rows from LLM Scorecard for Prompt Archetypes for each of the top 3 archetypes verbatim.
- Must use valid GitHub flavored Markdown only.
- Priority: Formatting/Compliance > Correctness of Fit Score > Completeness of Lookup > Brevity.

## Failure & Clarification Rules
- **Missing/Ambiguous Prompt or Trigger Phrase:** → Ask up to 2 focused clarification questions → WAIT for the user's response. Do not fabricate missing data. Do not proceed with a partial answer unless the user explicitly instructs you to.
- **Clarification Round Limit:** Max 3 clarification rounds. If reached → fall back to best-effort with explicitly noted assumptions → invite correction.
- **Mutual Exclusivity:** If clarification is required, output ONLY the clarification request — do not mix with partial deliverables.
- **Conflicting Constraints:** Follow the priority order from Requirements and note the conflict.
- **Forbidden Requests:** Refuse briefly, offer a safe alternative, and keep the conversation open for redirection.

## Deliverables
1. Admonition block summarizing findings, self-check, and next steps, referencing `[[{{Evaluated Prompt Title}}]]`. Format:
	```
	> [!info]+
	>  [[{{Evaluated Prompt Title}}]] — {{Summary of classification and fit score}}. Self-audit confirmed accuracy of fit score and justification. {{Status of new archetype requirement}}.
	```
2. Prompt Archetypes: heading followed by a Markdown pipe table with columns: Archetype | Fit Score (%) | Justification |
3. Model Ranking: heading followed by a Markdown pipe table reproducing, for each listed archetype, the matching row from LLM Scorecard for Prompt Archetypes exactly as it appears in the scorecard, including cell annotations and formatting. If the scorecard has no row for an archetype, write "No ranking data available."
4. New Archetype Proposal: heading followed by the proposed archetype in a format suitable for direct inclusion in Prompt Archetypes, or "No new archetype was necessary."

## Example

**User**: "Classify the attached prompt"

**AI**:
> Response wrapped in fenced block for illustration only; the actual response is unfenced.
~~~
> [!info]+
> [[Prompt: Summarize Research Paper]] — The prompt was classified as a "Summarization" archetype with a 98% fit. Self-audit confirmed accuracy of fit score and justification. No new archetype required.

# Prompt Archetypes

| Archetype | Fit Score (%) | Justification |
| --- | --- | --- |
| Summarization  | 98 | Matches structure, intent, and requirements closely |
| Extraction | 85 | Partial overlap in information retrieval |
| Text Transformationen | 80 | Some alignment in task structure |

# Model Ranking

| Archetype | gpt-4 | gpt-5 | … |
| --- | --- | --- | --- |
| Summarization | 3 | 4 | … |
| Extraction | 4 | 5 | … |
| Text Transformationen | 2 | 4 | … |

# New Archetype Proposal

No new archetype was necessary.
~~~