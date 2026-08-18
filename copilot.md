---
type: readme
tags: [AIAssistants, LLM, ObsidianCopilot, PromptEngineering, PromptManagement]
headline: "Obsidian Copilot prompts are organized by placement criteria and context databases"
secondary-types: [reference, prompt-index]
---

> [!overview] `§=this.headline`
> ![[Prompt Engineering.jpg|float:right|200]] Prompt engineering is a technique used to enhance the performance and output of AI chat models by carefully designing and structuring the input prompts.
> It involves understanding the AI's capabilities and limitations, and crafting prompts that guide the AI to produce more accurate, relevant, and contextually appropriate responses.
> This approach can significantly improve the quality of interactions with AI, making them more useful and engaging for users.

Some prompts are inspired by:
- [Collection of Chat Prompts](https://github.com/danielmiessler/fabric/tree/main/patterns)
- [Awesome ChatGPT Prompts](https://prompts.chat/)

# Obsidian Copilot Prompts

## Locations for Obsidian Copilot Prompts

Obsidian Copilot prompts can be placed in three locations:

1. **System Prompt in a Project**
   - Backed by `copilot/projects`.
1. **Slash (`/`) Command**
2. **Context Menu of a Note**

---

## Criteria for Placing Prompts

Use the following criteria to determine the appropriate location for a prompt:

| Prompt Feature                       | Suitable Location(s)                 | Reasoning                                                    |
| ------------------------------------ | ------------------------------------ | ------------------------------------------------------------ |
| Uses `@` content selectors           | Slash command only                   | These selectors are not supported elsewhere, except in chat. |
| Contains `{...}` note selector(s)    | Context menu action or slash command | Can be used in either a menu action or a slash command.      |
| Has static context data              | Project System Prompt                | Enables prompt caching.                                      |

By following these guidelines, you can ensure that your Obsidian Copilot prompts are placed in the most effective and functional location.

## Creating new Prompts

- [n8n Prompt Factory](http://localhost:5678/form/bd899615-735d-472a-9fbd-2a22bb8d011b): Upload a draft prompt or specification ⟶ the factory returns a perfected prompt in [[Inbox]].
- [n8n Agent Prompt Factory](http://localhost:5678/form/0adfaa59-0fe3-49e7-a0d5-3915852b94f9): Upload a draft specification ⟶ the factory returns an perfected n8n agent prompt in [[Inbox]]. 

# Context  Databases

| DB                                                   | Purpose                                                                                                                                |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| [[Annotated Prompt Template]]                        | A prompt template with all the important sections to generate high-impact prompts; Includes examples and descriptions                  |
| [[Folders]]                                          | A list of available folders. Used to find adequate locations for notes                                                                 |
| [[Context Data/Hyperparameters]]                     | Definitions of tunable LLM parameters with explanations. Meant to be included in system prompts                                        |
| [[Image Styles]]                                     | A list of style definitions available for AI image generation.                                                                         |
| [[Chat Prompt Operational Quality Checklist]]        | Criteria to assess and measure the quality of LLM prompts                                                                              |
| [[Context Data/LLM Scorecard for Prompt Archetypes]] | A LLM performance table of the fitness of LLMs from [[Models]] when processing archetypical workloads defined in [[Prompt Archetypes]] |
| [[Markdown Style Guide]]                             | Definition of Obsidian specific Markdown elements                                                                                      |
| [[Models]]                                           | List of LLMs of interest                                                                                                               |
| [[Note Type Definitions]]                            | Table of available note types for the `type` frontmatter property                                                                      |
| [[Note Type Definitions]]                            | Definitions of types (frontmatter `type`)  available for note classification                                                           |
| [[Obsidian Canvas Schema]]                           | Reference schema to allow LLMs the create Obsidian Canvas data                                                                         |
| [[Prompt Archetypes]]                                | A classification of LLM workloads for use in LLM fitness ranking                                                                       |

# Prompts
~~~base
filters:
  and:
    - file.inFolder("copilot")
formulas:
  Project: link(this,note["copilot-project-name"])
properties:
  note.copilot-command-model-key:
    displayName: Model
  file.name:
    displayName: Prompt
  note.copilot-project-description:
    displayName: Description
  note.copilot-project-model-key:
    displayName: Model
views:
  - type: table
    name: Obsidian Copilot Prompts
    filters:
      and:
        - file.inFolder("copilot/copilot-custom-prompts")
    groupBy:
      property: copilot-command-model-key
      direction: ASC
    order:
      - file.name
      - copilot-command-model-key
    columnSize:
      file.name: 428
  - type: table
    name: Project System Prompts
    filters:
      and:
        - file.inFolder("copilot/projects")
    groupBy:
      property: copilot-project-model-key
      direction: ASC
    order:
      - formula.Project
      - copilot-project-description
      - copilot-project-model-key
    sort:
      - property: formula.Project
        direction: ASC
    columnSize:
      formula.Project: 267
      note.copilot-project-description: 337
  - type: table
    name: Skills
    filters:
      and:
        - file.inFolder("copilot/Skills")
    order:
      - file.name
    columnSize:
      file.name: 428

~~~

# Resources

See [[Benchmarks & Leaderboards]]

