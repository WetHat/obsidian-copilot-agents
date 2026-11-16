Prompts, skills, and project system prompts for the [Obsidian Copilot](https://github.com/logancyang/obsidian-copilot) plugin.

This repository is a curated collection of reusable AI-assistant assets for use inside an Obsidian vault. The inventories below mirror the tracked contents of the repository.

- **Skills** — 12 parameterized, self-contained `SKILL.md` folders and 3 single-file prompt assets that extend the Copilot agent with specialized capabilities.
- **Custom prompts** — 40 slash-command and context-menu prompts for common writing, rewriting, and analysis tasks.
- **Project system prompts** — 7 persistent system prompts bound to Copilot projects, each with its own context inclusions.

# Repository Structure

```text
├── skills/                       # 12 SKILL.md skill folders + 3 single-file prompt assets
├── copilot-custom-prompts/       # 40 slash-command / context-menu prompts
├── projects/                     # 7 Copilot projects (project.md + optional AGENTS.md)
├── scripts/mcp-call.ps1          # Generic caller for remote MCP tools
├── system-prompts/               # Migrated custom system prompts
├── .gitignore                    # Excludes local-only assets (see below)
├── README.md
└── LICENSE                       # MIT
```

# Configuration

No MCP configuration file is tracked. The three servers the assets expect are registered in the Obsidian Copilot plugin's own settings (`customConnectors` in `.obsidian/plugins/copilot/data.json`), which is vault-local and not part of this repository:

| Server | Type | Launch |
| --- | --- | --- |
| `firecrawl` | local | `npx -y firecrawl-mcp` |
| `docker-mcp` | local | `docker mcp gateway run --profile obsidian` |
| `windmill` | remote | `http://localhost/api/mcp/w/obsidian/mcp` |

`scripts/mcp-call.ps1` reads an OpenCode-style config (`mcp.servers`) from `copilot/opencode.json` by default. That file is not tracked, so pass `-ConfigPath` to point the script at your own copy. The Windmill server reads its bearer token from the `WINDMILL_MCP_TOKEN` environment variable — or, failing that, from the Copilot plugin settings — and stays unreachable until that token and a local Windmill instance exist.

# Local-Only Assets

`.gitignore` keeps vault-specific material out of this repository, so cloning it does not provide:

- `copilot.md`, `memory/`, and `copilot-conversations/` — the vault index note, saved memories, and archived agent conversation transcripts.
- The Copilot Plus CLI skills: `copilot-web-search`, `copilot-web-fetch`, `copilot-youtube-transcript`, and `copilot-fetch-x`.
- The upstream MIT-licensed Obsidian skills: `obsidian-markdown`, `obsidian-bases`, `json-canvas`, and `obsidian-cli`.
- The local Miyo skills (`miyo-parse`, `miyo-search`) and the publish integrations (`symposium-publish`, `openartifacts-*`).
- Anything matching `*_legacy*`, and per-project build artifacts under `projects/*/outputs/`.

A working vault therefore shows more folders under `skills/` than this repository tracks: 18 directories locally, 12 of them tracked. The counts and tables below describe only the tracked set.

# Skills

Skills live in `skills/`. Directory-based skills contain a `SKILL.md` and, where needed, cross-platform CLI wrapper scripts or `references/` files. The directory also contains three standalone `.md` prompt assets, listed separately below.

## Obsidian Canvas and Diagrams

| Skill | Description |
| --- | --- |
| `canvas-content` | Resolve a `.canvas` file into a semantic Markdown report for classification, tagging, headline generation, or summarization. |
| `canvas-frontmatter` | Read, set, merge, and remove properties in `.canvas` frontmatter (`metadata.frontmatter`). |
| `mermaid-diagram` | Choose the optimal Mermaid diagram type for a specification and generate or edit valid Mermaid code. Ships 22 per-diagram-type reference files — flowchart, sequence, class, state, ER, Gantt, packet, event modeling, treemap, Ishikawa, railroad, and others — plus a syntax reference. |

## Note Content and Metadata

| Skill | Description |
| --- | --- |
| `define-term` | Define a term, abbreviation, or acronym in the sense fixed by the chat context, at the requested depth, as a plain section, cited footnote, or `[!def]` callout. Ships `references/examples.md`. |
| `extract-headline` | Generate a single, objective one-sentence headline from Markdown input. |
| `extract-tags` | Extract unique, semantically central tags from Markdown input. |
| `smart-brevity-summary` | Summarize notes or sections as a smart-brevity callout with a Tease, Lede, Why it matters, and optional Go Deeper links. |
| `link-agent-context-file` | Format a link to a `SKILL.md`, `AGENTS.md`, or `CLAUDE.md` file as a wikilink aliased to its parent folder name. Ships wrappers in `scripts/`. |

## Agent and Session Tooling

| Skill | Description |
| --- | --- |
| `model-name` | Report the model executing the current OpenCode session, resolved from `OPENCODE_SESSION_ID` by querying the OpenCode session database. Ships Windows wrappers in `scripts/`. |
| `ponytail` | Apply a lazy-senior-dev discipline to vault work: solve the whole task with the smallest complete change, climbing a reuse ladder before writing anything new. Vendored from an upstream MIT-licensed skill. |

## Web Research

| Skill | Description |
| --- | --- |
| `find-web-resources` | Find web resources for Markdown content and return them as descriptive Markdown links, up to a requested count. |

## Integrations

| Skill | Description |
| --- | --- |
| `openweather-forecast` | Produce a weather forecast for a location through the OpenWeatherMap MCP server in the Docker MCP Toolkit. |

## Single-File Prompt Assets

`skills/` also holds three standalone Markdown assets. These are not `SKILL.md` skills: they declare a `## Task`, `## Signature`, and `## Parameters` contract and are invoked through the `|>` skill-invocation operator documented in `system-prompts/`.

| Asset | Description |
| --- | --- |
| `ExplainCodeSnippet.md` | Step-by-step explanation of a code snippet or regular expression, adapted to the requested audience level and detail mode. |
| `ExtractTakeaways.md` | Concise, memorable takeaways with limits on count, sentences, and lead-in length. |
| `GroupListByTheme.md` | Organize a flat Markdown list into thematic groups under minimal, conventional headings. |

Three tracked skill folders ship CLI wrappers: `canvas-content` and `link-agent-context-file` provide `.cmd`, `.sh`, and `.ps1` launchers, and `model-name` provides `.cmd` and `.ps1`. Each `SKILL.md` documents its own invocation.

# Custom Prompts

`copilot-custom-prompts/` contains 40 prompts for Copilot's slash command and note context menu. Each file carries Copilot frontmatter — `copilot-command-slash-enabled`, `copilot-command-context-menu-enabled`, and `copilot-command-model-key` — so a prompt can be exposed on either surface and pinned to a specific model. Of the 40, 26 are slash-enabled, 18 are context-menu-enabled, and 32 pin a model.

Filenames use emoji prefixes as a visual grouping cue in the Copilot UI:

| Prefix | Count | Contents |
| --- | --- | --- |
| 🎓 | 3 | Analysis and learning — article evaluation, archetype ranking, image prompts. |
| 🖊️ | 15 | Writing, rewriting, and transformation — rewrite variants, translations, simplification, abstracts, definitions, LaTeX, tables, diagrams, emojification. |
| 📩 | 1 | PDF intake — `PDF to Markdown`. |
| — | 21 | Note and repository tooling — frontmatter upserts for headline, tags, type, and expiration; folder notes; cited term definitions; PDF outlines, tables of contents, and takeaways; prompt and skill audits; tool inventory; GitHub repo annotation; journal summaries; Flipboard sharing; bookmarking; workload reporting. |

The filenames in `copilot-custom-prompts/` are the authoritative prompt inventory.

# Projects

`projects/` holds 7 Copilot projects. Each `project.md` carries the project metadata — id, name, description, context inclusions and exclusions, web and YouTube URLs, and created/last-used timestamps. Only `Writing Assistant v1` keeps its system prompt body in `project.md`; it is also the only archived project (`copilot-project-archived-at`). The other six keep their instructions in an `AGENTS.md` file, paired with a one-line `CLAUDE.md` that imports it (`@AGENTS.md`).

Context inclusions are stored URL-encoded in `project.md`; the note names below are the decoded values.

| Project | Purpose | Context inclusions |
| --- | --- | --- |
| `Classify Note` | Upsert classification data into a note's frontmatter. | `Folders` |
| `Prompt Archetype Assessment` | Match prompt archetype activation to models. | `LLM Scorecard for Prompt Archetypes`, `Prompt Archetypes` |
| `Prompt Factory` | Create a production-ready prompt from a draft specification or prompt. | `Annotated Prompt Template`, `Prompt Operational Quality Checklist (POQC)` |
| `Prompt Perfecter` | Review and perfect prompts. | `Prompt Operational Quality Checklist (POQC)` |
| `Skill Factory` | Create production-ready skills. | `Annotated Skill Template`, `Skill Operational Quality Checklist (SOQC)`, `Agent Skills - Specification` |
| `Skill Perfecter` | Make a `SKILL.md` production-ready. | `Skill Operational Quality Checklist (SOQC)` |
| `Writing Assistant v1` | Turn a content sketch into a production-ready article. | `Obsidian flavored Markdown` |

The note names above are vault resources, not files in this repository.

# Scripts

`scripts/mcp-call.ps1` is a PowerShell 7 generic caller for the MCP tools registered in an OpenCode-style config. Code Mode's `execute` sandbox has no filesystem access, so a tool that needs a file's contents normally receives them as an inlined string — a transport where large payloads have been observed arriving corrupted. The script reads the file from disk and sends it over the server's own transport instead.

```pwsh
pwsh copilot/scripts/mcp-call.ps1 -ListTools
pwsh copilot/scripts/mcp-call.ps1 -Tool windmill_infer_content_type -Arg 'content=@AI/Agents/Foo.md'
```

`-Arg` takes `name=value` and repeats for multiple arguments; a value beginning with `@` reads that file. `-StripFrontmatter` removes YAML frontmatter from `@file` arguments, and `-Raw` prints the tool's text response verbatim. `-ConfigPath` overrides the config location, which defaults to `copilot/opencode.json` — a file this repository does not track. Only `remote` (HTTP/SSE) servers are supported, since `local` servers are stdio child processes and need a different transport.

# System Prompts

`system-prompts/` holds migrated custom system prompts. `Migrated Custom System Prompt.md` defines two context-specific overrides: an included "Obsidian flavored Markdown" section takes absolute precedence over conflicting formatting guidance, and the `|>` operator invokes a skill on its left operand, so `"Some text" |> ExtractTakeaways(listLimit=2)` is executed and replaced by its result before rendering.

# License

[MIT](LICENSE) © 2026 Peter Ernst
