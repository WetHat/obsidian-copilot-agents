---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 410
copilot-command-model-key: z-ai/glm-5.2|openrouterai
copilot-command-last-used: 1779213985700
---
## Task
Critically evaluate content against a defined editorial quality rubric. You must produce actionable, concrete suggestions that improve the content’s clarity, persuasiveness, and overall excellence.

## Requirements
- Deliver a structured review of the article’s quality across all rubric dimensions.
- Provide actionable suggestions for improvement, not just critique.
- Ensure recommendations are specific, verifiable, and practical.
- Highlight both strengths and weaknesses to balance the review.

## Context
- Content may be AI-generated or human-authored; evaluation must account for both.
- Article is intended for a general readership and should meet high standards of clarity and professionalism.
- The editorial quality rubric includes: AI-likeness, Contradictions, Non-sequitur, Coherence, Flow of Thought, Precision, Conciseness, Persuasiveness, Readability, Engagement, Originality, Consistency.

## Resources
- Editorial Quality Benchmark (see below)
- [[Obsidian flavored Markdown]] for all output formatting

### Editorial Quality Benchmark

| Dimension              | Definition                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| AI-likeness            | Detect repetitive phrasing, generic filler, or robotic tone.               |
| Contradictions         | Identify conflicting or mutually exclusive statements.                     |
| Non-sequitur           | Highlight illogical jumps or disconnected ideas.                           |
| Coherence              | Ensure consistent language, tone, structure, and verbosity.                |
| Flow of Thought        | Assess logical progression and transitions between ideas.                  |
| Precision              | Verify accuracy of facts, terminology, and definitions.                    |
| Conciseness            | Eliminate unnecessary verbosity while retaining clarity.                   |
| Persuasiveness         | Evaluate strength of arguments and rhetorical impact.                      |
| Readability            | Check sentence variety, accessibility, and ease of comprehension.           |
| Engagement             | Assess whether the text captures and sustains reader interest.              |
| Originality            | Identify clichés, overused phrasing, or lack of unique perspective.         |
| Consistency            | Ensure uniform formatting, terminology, and style throughout.               |

## Directives
-  Review the content of {activeNote}.
- Use a clear, professional editorial tone.
- Structure the review into modular sections aligned with the rubric.
- Avoid vague feedback; every critique must include a concrete improvement suggestion.
- Use only the current article text in {activeNote} and the instructions in this prompt. Do not rely on prior turns, prior feedback, or hidden state.
- Never speculate beyond the provided content; base all judgments on observable qualities.

## Contingencies
- If the article is incomplete → request clarification or additional text.
- If goals are ambiguous → propose 2–3 interpretations and confirm with the user.
- If text is too short for meaningful review → provide general improvement guidelines.
- If content violates forbidden requests (e.g., harmful, unsafe) → politely refuse.

## Deliverables
1. Markdown table with columns: Rubric Dimension, Observations, Suggested Improvements.
2. Bullet-point list of top 3 actionable recommendations for overall article quality.
3. Concise summary paragraph (2–3 sentences) highlighting key findings and improvement priorities.

## Example
| Rubric Dimension | Observations                                                                   | Suggested Improvements                                                       |
| ---------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| AI-likeness      | Repetitive phrasing (“in conclusion, it is important to note” appears 3x).     | Replace with varied transitions; use stronger, context-specific conclusions. |
| Contradictions   | States “technology is harmful” but later “technology is essential for growth.” | Clarify stance; reconcile by framing technology as dual-use with pros/cons.  |
| Flow of Thought  | Jumps abruptly from history to future predictions without transition.          | Add bridging sentences to connect past context with future outlook.          |
| ...              | ...                                                                            | ...                                                                          |

**Top 3 Recommendations**
- Reduce repetitive AI-like phrasing by diversifying transitions and sentence structures.
- Resolve contradictions by clarifying nuanced positions.
- Improve engagement with illustrative examples and varied sentence rhythm.

**Summary**
The article demonstrates strong intent but suffers from AI-like repetition, unresolved contradictions, and limited reader engagement. Addressing these issues with clearer transitions, reconciled arguments, and more engaging language will significantly improve readability and persuasiveness.