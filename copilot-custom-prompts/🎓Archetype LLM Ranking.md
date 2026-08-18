---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 0
copilot-command-model-key: gpt-5.6-terra|openai
copilot-command-last-used: 1786644436659
---
# Task

Evaluate and rank LLMs based on their performance when accessed via API for archetypical workloads.

# Context
The scorecard will be used by prompt engineers to determine the best LLM for workloads
# Resources

Reference Materials:

- [[Obsidian flavored Markdown]]
- [[Prompt Archetypes]]
- [[Archetype Benchmark Mapping Schema]]
- [[Models]]

# Requirements

- Only models from [[Models]] are evaluated
- All scoring must map directly to the 'Archetype' and 'Scoring Dimensions' defined in [[Prompt Archetypes]].
- All output must comply with [[Obsidian flavored Markdown]]
- Produce a concise scorecard with one row per archetype and columns for each LLM from [[Models]]
- Each archetype must be individually scored (0–6) across all models from [[Models]]. using the Scoring Bands definition.
- Ensure all outputs are accurate, complete, and relevant to the request.
- Maintain a neutral, analytical tone.
- Attach exactly one consolidated footnote to each model header covering its exact API mapping, reasoning level, verified modalities, deployment constraints, benchmark sources, and any `†` inference with confidence.
- Always prioritize official API-based benchmark data. 
- Only generate the requested output; do not include reasoning steps or intermediate results.

## Capability Gate

Before scoring an archetype, verify that the exact API model supports its required capabilities using exact-model API documentation.
- Unsupported ⟶ `0`
- Partial or deployment-dependent ⟶ score supported scope, prefixed `†`
- Unknown ⟶ `0` ; do not infer support; Add remark to footnote 
- Verify input and output modalities independently; understanding does not imply generation
- Never inherit capabilities from vendors, model families, sibling models, UI products, routers, or separate endpoints
- Proxy evidence may estimate performance only after capability support is verified

# Directives

1. @websearch first and gather the most up-to-date data leaderboards, benchmarks, articles, vendor documentation, for the models using the Benchmark Mapping Schema
2. For each archetype from [[Prompt Archetypes]], assign a score across all models from [[Models]] using the Scoring Bands definitions
3. Resolve each name from [[Models]] to an exact API model ID; document the mapping in its consolidated footnote.
4. Verify capabilities from official exact-model API documentation before consulting performance benchmarks.
5. Score only supported workloads using this evidence order: official API benchmarks ⟶ reproducible independent API benchmarks ⟶ reputable leaderboards ⟶ UI or wrapper proxies.
6. Use the highest documented reasoning level and record it in the model footnote.
7. Before finalizing, verify that:
	- Unsupported workloads score `0`
	- Partial or inferred scores carry `†`
	- Multimodal input and output support were evaluated separately
	- No capability was inherited from a related model
	- All row maxima are highlighted correctly

# Contingencies

- Required input or context is missing or ambiguous ⟶ pause and request explicit clarification from the user
- Model name does not match any LLM name used in benchmark or leaderboard data ⟶ map to the most likely name and document that mapping as footnote
- Exact API model cannot be resolved ⟶ request clarification; do not assume a mapping
- Capability evidence is missing or ambiguous ⟶ record in footnote and score 0 ; do not infer support
- Performance evidence is missing for a verified capability ⟶ use the closest applicable proxy, prefix the score with `†`, and document the source, metric, and confidence
- Official API based benchmark data unavailable ⟶ infer from UI-based or third-party wrapper KPIs, but you MUST prefix the score with a marker (e.g., `†`) and document the exact inference source, proxy metric, and confidence level in the model's consolidated footnote.

# Deliverables

1. An Obsidian custom callout block for takeaways (no heading):
   > [!Takeaways]+
    > {{Takeaways}}
2. Scorecard: Markdown pipe table with one row per archetype and columns for each LLM; the highest score(s) in each row highlighted as `==**{{score}}**==`; if multiple, highlight all
3. Sources: List of Markdown links to sources on the web, used for scoring (with descriptive link names)

# Example

| Archetype     | LLM-A     | LLM-B[^1] | LLM-C     |
| ------------- | --------- | --------- | --------- |
| Summarization | 4         | ==**5**== | 3         |
| Coding        | 3         | 3         | ==**4**== |
| Reasoning     | ==**4**== | ==**4**== | 8         |

{{List of source citations}}

[^1]: Score for LLM-B on Summarization inferred from UI-based benchmarks due to lack of API data.
