## Task
Generate a step-by-step explanation of a provided code snippet or regular expression (REGEX). Clarify its purpose, logic, edge cases, related design/algorithmic patterns, and relevant considerations for software developers. Adapt the explanation to the specified audience level and detail mode.

## Signature
In: Markdown or plain text code snippet or REGEX

Parameters:
1. detailMode: enum[concise|standard|comprehensive] (default=standard) 
    - concise: Bullet points, minimal detail.
    - standard: Short paragraphs/lists, covers all required aspects.
    - comprehensive: Full narrative, extended discussion, rich formatting.
2. audienceLevel: enum[beginner|intermediate|expert] (default=intermediate) 
    - beginner: Analogies, minimal jargon.
    - intermediate: Balanced technical depth
    - expert: Full technical depth, design trade-offs, performance, edge cases.
3. languageHint: string (default=auto) — Code language (e.g., "Python", "JavaScript", "REGEX"), or `auto` to auto-detect.

Invocation: `{{Input}} |> ExplainCodeSnippet(detailMode={{detailMode}}, audienceLevel={audienceLevel}}, languageHint={{languageHint}})`

Out: Markdown

## Dependencies
Requires: [[Obsidian flavored Markdown]]

## Rules
- Local rules override global context
- If languageHint= inferred, auto-detect the language and assign. If confidence is low, still infer and add a warning
- Explanation must cover all required aspects with the required level of detail per detailMode  & audienceLevel
- Output must be [[Obsidian flavored Markdown]]; No footnotes!
- Quote only minimal code fragments for clarity; never the entire snippet unless it is one line

## Process
Return:
1. Explanation:  tailored to detailMode (all mode specific aspects covered)  & audienceLevel (level specific writing style used)
2. Errors: list of flagged errors , if present
3. Warnings: list of flagged warnings, if present

## Contingency
- Empty or malformed input → flag in Warnings
- Parameter(s) missing ⟶ use default(s)
- Multi‑language or unusually large input → flag in Warnings
- Malicious/unsafe code → flag in Errors with reasoning.
- Missing external context (e.g., dependencies) → flag in Warnings with assumptions.
- Unsupported parameter values → fall back to defaults & flag in Warnings 

## Example
Invocation (inline): 
~~~
`def add(a, b): return a + b` |> ExplainCodeSnippet(detailMode=concise, audienceLevel=beginner, languageHint=auto)
~~~

Output:
~~~
### Explanation
- This function, called `add`, takes two inputs and returns their sum.
- It uses the `+` operator to add the values.
- Useful for simple addition tasks.
~~~