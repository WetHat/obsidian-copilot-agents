Prompts, skills, and project system prompts for the [Obsidian Copilot](https://github.com/logancyang/obsidian-copilot) plugin.

This repository is a curated collection of reusable AI-assistant assets for use inside an Obsidian vault. The inventories below mirror the tracked contents of the repository.

- **Skills** — parameterized, self-contained instructions (`SKILL.md` folders) and single-file prompt assets that extend the Copilot agent with specialized capabilities.
- **Custom prompts** — slash-command and context-menu prompts for common writing, rewriting, and analysis tasks.
- **Project system prompts** — persistent system prompts bound to Copilot projects, each with its own model and context inclusions.

# Repository Structure

```text
├── skills/                       # 10 SKILL.md skill folders + 4 single-file prompt assets
├── copilot-custom-prompts/       # 43 slash-command / context-menu prompts
├── projects/                     # 10 Copilot projects (project.md + optional AGENTS.md)
├── scripts/mcp-call.ps1          # Generic caller for remote MCP tools
├── system-prompts/               # Migrated custom system prompts
├── opencode.json                 # OpenCode config: skills path + MCP servers
├── .gitignore                    # Excludes local-only assets (see below)
├── README.md
└── LICENSE                       # MIT
```

# Configuration

`opencode.json` registers the `skills/` directory and three MCP servers:

| Server | Type | Launch |
| --- | --- | --- |
| `firecrawl` | local | `npx -y firecrawl-mcp` |
| `docker-mcp` | local | `docker mcp gateway run --profile obsidian` |
| `windmill` | remote | `http://localhost/api/mcp/w/obsidian/mcp` |

Two values must be supplied locally. The `skills` path is absolute (`~/OneDrive/Documents/ObsidianVaults/WetHat Lab/copilot/skills`) and must be repointed after cloning. The Windmill server reads its bearer token from the `WINDMILL_MCP_TOKEN` environment variable and stays unreachable until that variable and a local Windmill instance exist.

# Local-Only Assets

`.gitignore` keeps vault-specific material out of this repository, so cloning it does not provide:

- `copilot.md`, `memory/`, and `copilot-conversations/` — the vault index note, saved memories, and archived agent conversation transcripts.
- The Copilot Plus CLI skills: `copilot-web-search`, `copilot-web-fetch`, `copilot-youtube-transcript`, and `copilot-fetch-x`.
- The upstream MIT-licensed Obsidian skills: `obsidian-markdown`, `obsidian-bases`, `json-canvas`, and `obsidian-cli`.
- The local Miyo skills (`miyo-parse`, `miyo-search`) and the publish integrations (`symposium-publish`, `openartifacts-*`).
- Per-project build artifacts under `projects/*/outputs/`.

# Skills

Skills live in `skills/`. Directory-based skills contain a `SKILL.md` and, where needed, cross-platform CLI wrapper scripts or `references/` files. The directory also contains four standalone `.md` prompt assets, listed separately below.

## Obsidian Canvas and Diagrams

| Skill | Description |
| --- | --- |
| `canvas-content` | Resolve a `.canvas` file into a semantic Markdown report for classification, tagging, headline generation, or summarization. |
| `canvas-frontmatter` | Read, set, merge, and remove properties in `.canvas` frontmatter (`metadata.frontmatter`). |
| `mermaid-diagram` | Choose the optimal Mermaid diagram type for a specification and generate or edit valid Mermaid code. Ships 17 per-diagram-type reference files — flowchart, sequence, class, state, ER, Gantt, mindmap, C4, and others — plus a syntax reference. |

## Note Content and Metadata

| Skill | Description |
| --- | --- |
| `define-term` | Define a term, abbreviation, or acronym in the sense fixed by the chat context, at the requested depth, as a plain section, cited footnote, or `[!def]` callout. Ships `references/examples.md`. |
| `extract-headline` | Generate a single, objective one-sentence headline from Markdown input. |
| `extract-tags` | Extract unique, semantically central tags from Markdown input. |
| `smart-brevity-summary` | Summarize notes or sections as a smart-brevity callout with a Tease, Lede, Why it matters, and optional Go Deeper links. |
| `link-agent-context-file` | Format a link to a `SKILL.md`, `AGENTS.md`, or `CLAUDE.md` file as a wikilink aliased to its parent folder name. Ships wrappers in `scripts/`. |

## Web Research

| Skill | Description |
| --- | --- |
| `find-web-resources` | Find web resources for Markdown content and return them as descriptive Markdown links, up to a requested count. |

## Integrations

| Skill | Description |
| --- | --- |
| `openweather-forecast` | Produce a weather forecast for a location through the OpenWeatherMap MCP server in the Docker MCP Toolkit. |

## Single-File Prompt Assets

`skills/` also holds four standalone Markdown assets. These are not `SKILL.md` skills: they declare a `## Task`, `## Signature`, and `## Parameters` contract and are invoked through the `|>` skill-invocation operator documented in `system-prompts/`.

| Asset | Description |
| --- | --- |
| `ExplainCodeSnippet.md` | Step-by-step explanation of a code snippet or regular expression, adapted to the requested audience level and detail mode. |
| `ExtractTakeaways.md` | Concise, memorable takeaways with limits on count, sentences, and lead-in length. |
| `GroupListByTheme.md` | Organize a flat Markdown list into thematic groups under minimal, conventional headings. |
| `MakeWebResourceList.md` | Return up to a requested number of relevant web resources as descriptive Markdown links. |

`link-agent-context-file` is the only tracked skill folder that ships CLI wrappers: `.cmd` for Windows, `.sh` for macOS and Linux, and `.ps1` for PowerShell, in its `scripts/` directory. Each `SKILL.md` documents its own invocation.

# Custom Prompts

`copilot-custom-prompts/` contains 43 prompts for Copilot's slash command and note context menu. Each file carries Copilot frontmatter — `copilot-command-slash-enabled`, `copilot-command-context-menu-enabled`, and `copilot-command-model-key` — so a prompt can be exposed on either surface and pinned to a specific model.

Filenames use emoji prefixes as a visual grouping cue in the Copilot UI:

| Prefix | Count | Contents |
| --- | --- | --- |
| 🎓 | 5 | Analysis and learning — article evaluation and insights, archetype ranking, canvas concept maps, image prompts. |
| 🖊️ | 18 | Writing, rewriting, and transformation — rewrite variants, translations, simplification, takeaways, abstracts, definitions, LaTeX, tables, diagrams, emojification. |
| 📩 | 1 | PDF intake — `PDF to Markdown`. |
| — | 19 | Note and repository tooling — frontmatter upserts for headline, tags, and type; folder notes; PDF outlines, tables of contents, and takeaways; prompt and skill audits; tool inventory; GitHub repo annotation; journal summaries; Flipboard sharing. |

The filenames in `copilot-custom-prompts/` are the authoritative prompt inventory.

# Projects

`projects/` holds 10 Copilot projects. Each `project.md` carries the project metadata — id, name, description, context inclusions, and timestamps — and, for `Summarize (pdf) v1` and `Writing Assistant v1`, the system prompt body as well. The other eight projects keep their instructions in an `AGENTS.md` file, paired with a one-line `CLAUDE.md` that imports it (`@AGENTS.md`).

Context inclusions are stored URL-encoded in `project.md`; the note names below are the decoded values.

| Project | Purpose | Context inclusions |
| --- | --- | --- |
| `Classify Note` | Upsert classification data into a note's frontmatter. | `Folders` |
| `Define Terms` | Apply the `define-term` skill's footnote output to the active note, one term per turn. | — |
| `Prompt Archetype Assessment` | Match prompt archetype activation to models. | `LLM Scorecard for Prompt Archetypes`, `Prompt Archetypes` |
| `Prompt Factory` | Create a production-ready prompt from a draft specification or prompt. | `Annotated Prompt Template`, `Prompt Operational Quality Checklist (POQC)` |
| `Prompt Perfecter` | Review and perfect prompts. | `Prompt Operational Quality Checklist (POQC)` |
| `Skill Auditor` | Audit skills and suggest improvements. | `Skill Analysis Rubric` |
| `Skill Factory` | Create production-ready skills. | `Annotated Skill Template`, `Skill Analysis Rubric` |
| `Skill Perfecter` | Make a `SKILL.md` production-ready. | `Skill Operational Quality Checklist (SOQC)` |
| `Summarize (pdf) v1` | Summarize a PDF for retrieval-augmented generation (RAG). | `Obsidian flavored Markdown` |
| `Writing Assistant v1` | Turn a content sketch into a production-ready article. | `Obsidian flavored Markdown` |

The note names above are vault resources, not files in this repository.

# Scripts

`scripts/mcp-call.ps1` is a PowerShell 7 generic caller for the MCP tools registered in `opencode.json`. Code Mode's `execute` sandbox has no filesystem access, so a tool that needs a file's contents normally receives them as an inlined string — a transport where large payloads have been observed arriving corrupted. The script reads the file from disk and sends it over the server's own transport instead.

```pwsh
pwsh copilot/scripts/mcp-call.ps1 -ListTools
pwsh copilot/scripts/mcp-call.ps1 -Tool infer_content_type -Arg 'content=@AI/Agents/Foo.md'
```

`-Arg` takes `name=value` and repeats for multiple arguments; a value beginning with `@` reads that file. `-StripFrontmatter` removes YAML frontmatter from `@file` arguments, and `-Raw` prints the tool's text response verbatim. Only `remote` (HTTP/SSE) servers are supported, since `local` servers are stdio child processes and need a different transport.

# System Prompts

`system-prompts/` holds migrated custom system prompts. `Migrated Custom System Prompt.md` defines two context-specific overrides: an included "Obsidian flavored Markdown" section takes absolute precedence over conflicting formatting guidance, and the `|>` operator invokes a skill on its left operand, so `"Some text" |> ExtractTakeaways(listLimit=2)` is executed and replaced by its result before rendering.

# License

[MIT](LICENSE) © 2026 Peter Ernst
