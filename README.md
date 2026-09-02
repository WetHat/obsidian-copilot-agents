Prompts, skills, and project system prompts for the [Obsidian Copilot](https://github.com/logancyang/obsidian-copilot) plugin.

This repository is a curated collection of reusable AI-assistant assets for use inside an Obsidian vault. The inventories below mirror the current contents of the repository:

- **Skills** — parameterized, self-contained instructions (`SKILL.md` files) that extend the Copilot agent with specialized capabilities such as web search, document parsing, diagram generation, and Obsidian-specific syntax.
- **Custom prompts** — slash-command and context-menu prompts for common writing, rewriting, and analysis tasks.
- **Project system prompts** — persistent system prompts bound to Copilot projects, each with its own model, temperature, and context inclusions.

# Repository Structure

```text
├── copilot.md                    # Index note: prompt placement criteria & context databases
├── opencode.json                 # OpenCode configuration for the skills directory
├── skills/                       # Agent skills (SKILL.md + optional CLI wrappers)
├── copilot-custom-prompts/       # Slash-command / context-menu prompts
├── projects/                     # Copilot project configurations and prompts
├── system-prompts/               # Migrated custom system prompts
├── memory/                       # Saved memories & recent conversation summaries
├── copilot-conversations/        # Archived agent conversation transcripts
└── LICENSE                       # MIT
```

# Configuration

`opencode.json` adds `skills/` to OpenCode's skill search path and enables the local Firecrawl and Docker MCP integrations used by some skills. Folder-based skills are defined by a `SKILL.md` file; standalone Markdown files in `skills/` are reusable prompt assets.

# Skills

Skills live in `skills/`. Directory-based skills contain a `SKILL.md` and, where needed, cross-platform CLI wrapper scripts. The directory also contains standalone `.md` skill assets.

## Web and Media

The `copilot-*` skills use Copilot services. `copilot-web-fetch`, `copilot-fetch-x`, and `copilot-youtube-transcript` require Copilot Plus; `copilot-web-search` also supports a configured Self-Host provider. `find-web-resources` is a general resource-finding skill and does not depend on Copilot Plus.

| Skill | Description |
| --- | --- |
| `copilot-web-search` | Search the web for current information via Copilot Plus. |
| `copilot-web-fetch` | Fetch and read the full contents of a specific web page as clean Markdown. |
| `copilot-fetch-x` | Fetch the content of an X (Twitter) post. |
| `copilot-youtube-transcript` | Fetch the transcript of a YouTube video. |
| `find-web-resources` | Find and verify relevant web resources for Markdown content. |

## Local Document and Vault Tools

| Skill | Description |
| --- | --- |
| `miyo-parse` | Parse a local PDF or EPUB into Markdown/text with the local Miyo CLI — no cloud parser, no vault indexing required. |
| `miyo-search` | Semantic (meaning-based) search over the vault via the local Miyo app. |
| `obsidian-cli` | Use the official Obsidian CLI for app-dependent operations such as open notes, workspace state, queries, and plugin commands. |

## Obsidian Authoring and Formats

| Skill | Description |
| --- | --- |
| `obsidian-markdown` | Create and edit Obsidian-specific Markdown, including wikilinks, embeds, callouts, properties, tags, and comments. |
| `obsidian-bases` | Create and edit Obsidian Bases (`.base` files) with valid YAML schemas, filters, formulas, and views. |
| `json-canvas` | Create and edit JSON Canvas (`.canvas`) files with valid nodes, edges, groups, and referential integrity. |
| `mermaid-diagram` | Choose the optimal Mermaid diagram type for a specification and generate or edit valid Mermaid code. |

## Publishing and Integrations

| Skill | Description |
| --- | --- |
| `openartifacts-publish` | Publish, update, or withdraw an existing Markdown note through OpenArtifacts' host-owned review flow. |
| `openweather-forecast` | Get a local weather forecast through the Docker MCP Toolkit's OpenWeatherMap server. |

## Content Extraction and Transformation

| Skill | Description |
| --- | --- |
| `extract-headline` | Generate a single, objective one-sentence headline from Markdown input. |
| `extract-tags` | Extract unique, semantically central tags from Markdown input. |
| `DefineTerm.md` | Generate a contextually relevant, parameterized definition for a term or acronym. |
| `ExplainCodeSnippet.md` | Explain a code snippet or regular expression. |
| `ExtractTakeaways.md` | Extract concise, memorable takeaways from content. |
| `GroupListByTheme.md` | Organize a flat Markdown list into thematic groups. |
| `MakeWebResourceList.md` | Compile a list of relevant, verified web resources. |

Skills that call local or external tools include `.cmd` wrappers for Windows and `.sh` wrappers for macOS and Linux. Some also include a PowerShell wrapper; each skill's `SKILL.md` documents its invocation.

# Custom Prompts

`copilot-custom-prompts/` contains prompts for Copilot's slash command and note context menu, organized by use case. Current groups include:

- **Document processing** — PDF outlines, tables of contents, takeaways, and PDF-to-Markdown conversion
- **Analysis and learning** — article evaluation and insights, LLM tuning, archetype ranking, image prompts, and Canvas concept maps
- **Writing, rewriting, and structured Markdown** — headlines, tags, definitions, takeaways, diagrams, README folder notes, translations, grammar fixes, and rewrite variants

The filenames in `copilot-custom-prompts/` are the authoritative prompt inventory.

# Projects

`projects/` holds Copilot project system prompts. Each project defines its own model, temperature, max tokens, and context inclusions:

| Project | Purpose |
| --- | --- |
| `Classify Note` | Upsert classification data into a note's frontmatter. |
| `Prompt Archetype Assessment` | Match prompt archetype activation to models. |
| `Prompt Engineer` | Create a production-ready prompt from a draft specification or prompt. |
| `Prompt Perfecter` | Review and perfect prompts. |
| `Skill Auditor` | Audit skills and suggest improvements. |
| `Skill Engineer v7` | Create production-ready skills. |
| `Skill Perfecter` | Make a `SKILL.md` production-ready. |
| `Summarize (pdf) v1` | Summarize a PDF for retrieval-augmented generation (RAG). |
| `Writing Assistant v1` | Turn a content sketch into a production-ready article. |

# Other Directories

- **`system-prompts/`** — Migrated custom system prompts, e.g. context-specific overrides for Obsidian-flavored Markdown and skill invocation syntax (`|>`).
- **`memory/`** — Saved memories (user identity, communication preferences) and summaries of recent conversations.
- **`copilot-conversations/`** — Archived agent conversation transcripts.

# License

[MIT](LICENSE) © 2026 Peter Ernst
