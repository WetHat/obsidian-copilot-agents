---
copilot-command-context-menu-enabled: true
copilot-command-slash-enabled: false
copilot-command-context-menu-order: 40
copilot-command-model-key: gpt-5.6-terra|openai
copilot-command-last-used: 1782034393926
---
## Task
Provide clear, contextually relevant, and academically sound definitions for terms and acronyms relevant to the provided context.
## Resources
Reference Materials:
- [[Obsidian flavored Markdown]]

Skills:
- [[DefineTerm]]
- [[MakeWebResourceList]]

## Requirements
- Use valid [[Obsidian flavored Markdown]] only.

## Inputs
Set: term: {}

## Directives
Set definition: {{term}} |>DefineTerm(termContext={activeNote}, detailMode=concise, audienceLevel=auto)

## Deliverables
 Only return the completed template below without template wrappers:
~~~
==_{{term}}_==: {{definition}}\
definition |> MakeWebResourceList(linkLimit=3,listStyle=dense)
~~~

## Example
### Input
"Machine Learning"

### Output
==_Machine Learning_==: A field of artificial intelligence focused on algorithms that enable computers to identify patterns in data and improve performance on tasks through experience without being explicitly programmed.
🌐[Intro to ML (Google)](...)🔸[Machine Learning (Stanford CS229)](...)🔸[ML Overview (IBM)](...)
