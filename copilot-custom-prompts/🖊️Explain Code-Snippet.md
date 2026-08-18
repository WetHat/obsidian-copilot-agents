---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 200
copilot-command-model-key: z-ai/glm-5.2|openrouterai
copilot-command-last-used: 1780690324797
---
## Task
Generate a comprehensive explanation of the provided code snippet using the `ExplainCodeSnippet` skill.

## Inputs
Set
- `codeSnippet`:  {}
- `detailMode`: `comprehensive`
- `audienceLevel`: `expert`
- `languageHint`: `auto`

## Resources
- Skill: [[ExplainCodeSnippet]]
## Requirements
1. Use the skill signature exactly as defined in the resources.
2. Do not invent, substitute, or infer missing code or context.

## Deliverables
Return only the completed template below with all placeholders resolved and without wrappers:
~~~
{{ codeSnippet |> ExplainCodeSnippet(detailMode={{detailMode}}, audienceLevel={{audienceLevel}}, languageHint={{languageHint}}) }}

- - -

> Depth: {{detailMode}}; Audience: {{audienceLevel}}; Code Language: {{languageHint}}
~~~