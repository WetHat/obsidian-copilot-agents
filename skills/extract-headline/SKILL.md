---
name: extract-headline
description: >-
  Generate a single, objective one-sentence headline from Markdown input.
  Use when creating, reviewing, or improving note titles and headlines; not for ordinary content editing.
metadata:
  copilot-enabled-agents: codex,opencode
---

# Extract Headline

## Output
One plain-text line — no commentary, Markdown, or surrounding formatting.

## Input
- Markdown text.

## Requirements
- Headline is a single sentence, ≤ 30 tokens, with no period at the end.
- Sentence case: capitalize the first word and proper nouns only.
- Objective and factual; use only information present in the input.
- Match the input's register and terminology; keep the framing factual and neutral.
- Prefer the input's own wording; introduce no facts or features absent from the input.

## Contingency
- Empty, whitespace-only, or input without a clear main idea ⟶ return `"Unable to generate a headline due to insufficient content"`.

## Example
- Input: "Researchers report that recent advances in machine learning have significantly improved natural language processing systems."
- Output: "Recent machine learning advances significantly improve natural language processing systems"