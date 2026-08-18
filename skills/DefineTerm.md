## Task
Generate a contextually relevant, parameterized definition for a given term or acronym, adapting detail and technical depth to user-specified preferences and context.

## Signature
In: Term or acronym (Markdown)

Parameters:
1. termContext: Markdown or `none` (default=none) — Context in which the term is used. If `none`, the most common definition is used; otherwise, the definition is tailored to the provided context.
2. detailMode: enum[concise|standard|comprehensive] (default=standard) — Controls the depth and formatting of the definition.
   - concise: Single-sentence or inline definition only; minimal context, just the essential meaning; best for glossaries, tooltips, or quick reference.
   - standard: Clear, structured explanation in short paragraphs and/or lists; covers definition, purpose, and typical usage; balanced brevity and completeness; best for documentation and general readers.
   - comprehensive: Full narrative with extended detail and rich formatting; covers definition, purpose, logic, considerations, examples, and related terms; best for training materials, technical manuals, or deep dives.
3. audienceLevel: enum[beginner|intermediate|expert|auto] (default=auto) — Adjusts technical depth and language style.
   - beginner: Simple language, minimal jargon; use analogies and everyday examples; best for onboarding, non-technical readers, or students.
   - intermediate: Balanced technical depth; some jargon explained, assumes moderate familiarity; best for professionals or general documentation.
   - expert: Technical precision, assumes strong background knowledge; includes design trade-offs, performance considerations, and edge cases; best for engineers, researchers, or advanced users.
   - auto: Match style, tone, and register of termContext.

Invocation: `{{input}} |> DefineTerm(termContext={{termContext}}, detailMode={{detailMode}}, audienceLevel={{audienceLevel}})`

Out: Single well-structured, contextually adapted [[Obsidian flavored Markdown]] section

## Dependencies
Requires: [[Obsidian flavored Markdown]]

## Rules
- Adapt structure and length detailMode.
- Tailor style, tone, technical depth, analogies, and terminology to audienceLevel.
- Use termContext it to disambiguate and tailor the definition
- Output must be factually correct and contextually relevant.

## Process
1. Validate input type and parameters.
2. Use termContext to determine the most relevant definition
3. Generate the definition, adapting structure, length, and language to detailMode and audienceLevel.
4. Return the result using the **Output Format**

## Contingencies
- Empty/unrecognized input or no definition found → "Definition not found."
- Insufficient context ⟶ return the most common definition.
- Multiple meanings exist ⟶ select the most relevant to termContext
- termContext=none ⟶ use the most common definition
- Parameter(s) are missing or invalid ⟶ use default(s)
- No valid definition is found ⟶ return "Definition not found."
- audienceLevel=auto but termContext is insufficient to determine style, tone and register ⟶ Set audienceLevel: intermediate

## Output Format
A single [[Obsidian flavored Markdown]] section (no headings/callouts/blockquotes), paragraphs separated by empty lines, **Angle Bracket** rule applied.

## Examples
- Invocation: `"RAM" |> DefineTerm(termContext=none, detailMode=concise, audienceLevel=beginner)`
- Output: **RAM (Random Access Memory)** is the short‑term memory of a computer, where it quickly stores and uses information while you’re working, similar to how your brain remembers things just for the moment.

- Invocation: `"ECG" |> DefineTerm(termContext=Medical, detailMode=standard, audienceLevel=intermediate)`
- Output: **ECG (Electrocardiogram)** is a medical test that records the electrical activity of the heart over a period of time. It is commonly used to detect heart problems, monitor heart health, and guide treatment decisions. The test involves placing electrodes on the skin to measure and display the heart's electrical signals as a graph.