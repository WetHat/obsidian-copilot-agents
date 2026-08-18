# obsidian-copilot-agents

Prompts, skills, and project system prompts for the [Obsidian Copilot](https://github.com/logancyang/obsidian-copilot) plugin.

This repository is a curated collection of reusable AI-assistant assets for use inside an Obsidian vault:

- **Skills** — parameterized, self-contained instructions (`SKILL.md` files) that extend the Copilot agent with specialized capabilities such as web search, document parsing, diagram generation, and Obsidian-specific syntax.
- **Custom prompts** — slash-command and context-menu prompts for common writing, rewriting, and analysis tasks.
- **Project system prompts** — persistent system prompts bound to Copilot projects, each with its own model, temperature, and context inclusions.

## Repository Structure

```
├── copilot.md                    # Index note: prompt placement criteria & context databases
├── skills/                       # Agent skills (SKILL.md + optional CLI wrappers)
├── copilot-custom-prompts/       # Slash-command / context-menu prompts
├── projects/                     # Copilot project system prompts
├── system-prompts/               # Migrated custom system prompts
├── memory/                       # Saved memories & recent conversation summaries
├── copilot-conversations/        # Archived agent conversations
└── LICENSE                       # MIT
```

## Skills

Skills live in `skills/`. Each skill is a folder containing a `SKILL.md` (and, where needed, cross-platform CLI wrapper scripts) or a standalone `.md` file.

### Web & media (Copilot Plus)

| Skill | Description |
| --- | --- |
| `copilot-web-search` | Search the web for current information via Copilot Plus. |
| `copilot-web-fetch` | Fetch and read the full contents of a specific web page as clean Markdown. |
| `copilot-fetch-x` | Fetch the content of an X (Twitter) post. |
| `copilot-youtube-transcript` | Fetch the transcript of a YouTube video. |

### Local document processing (Miyo)

| Skill | Description |
| --- | --- |
| `miyo-parse` | Parse a local PDF or EPUB into Markdown/text with the local Miyo CLI — no cloud parser, no vault indexing required. |
| `miyo-search` | Semantic (meaning-based) search over the vault via the local Miyo app. |

### Obsidian authoring

| Skill | Description |
| --- | --- |
| `obsidian-markdown` | Create and edit Obsidian-specific Markdown: wikilinks, embeds, block references, callouts, properties, tags, comments. |
| `obsidian-bases` | Create and edit Obsidian Bases (`.base` files) with valid YAML schemas, filters, formulas, and views. |
| `obsidian-cli` | Use the official Obsidian CLI for app-dependent operations (open notes, workspace state, Bases queries, plugin commands). |
| `json-canvas` | Create and edit JSON Canvas (`.canvas`) files with valid nodes, edges, groups, and referential integrity. |
| `mermaid-diagram` | Choose the optimal Mermaid diagram type for a specification and generate or edit valid Mermaid code. |
| `symposium-publish` | Publish, update, or withdraw a Markdown note through Symposium's host-owned review flow. |

### Content extraction

| Skill | Description |
| --- | --- |
| `extract-headline` | Generate a single, objective one-sentence headline from Markdown input. |
| `extract-tags` | Extract unique, semantically central tags from Markdown input. |
| `DefineTerm` | Generate a contextually relevant, parameterized definition for a term or acronym. |
| `ExplainCodeSnippet` | Explain a code snippet. |
| `ExtractTakeaways` | Extract key takeaways from content. |
| `GroupListByTheme` | Group list items by theme. |
| `MakeWebResourceList` | Compile a list of web resources. |

## Custom Prompts

`copilot-custom-prompts/` contains prompts for the Copilot slash command and note context menu, organized by use case:

- **Document processing** — `Document Outline (pdf)`, `Table of Contents (pdf)`, `Takeaways (pdf)`, `PDF to Markdown`
- **Analysis & learning** — `LLM Tuning`, `Archetype LLM Ranking`, `Article Evaluator`, `Article Insights`, `Skill Documenter`, `Make Canvas Concept Map`, `Make Image Prompt`, `Cybersecurity Briefing`
- **Writing & rewriting** — headline, hashtags, journal summary, takeaways, abstracts, definitions (callout/footnote/inline), Mermaid concept maps & diagrams, svgbob diagrams, symlinks, README (folder note), and rewrite variants (callout, codeblock, LaTeX math, sorted definition list, structured Markdown, table, tweet, longer, shorter, simplify, translate EN/DE, emojify, fix grammar, Jeopardy)

## Projects

`projects/` holds Copilot project system prompts. Each project defines its own model, temperature, max tokens, and context inclusions:

| Project | Purpose |
| --- | --- |
| `Classify Note` | Classify notes against vault note-type definitions. |
| `CompSci Assistant v4` | Ask about a CSC. |
| `Flip It v2` | Flip an article to Flipboard. |
| `Prompt Archetype Assessment` | Analyze prompt archetype activation strength. |
| `Prompt Engineer` | Turn a draft spec/prompt into a "goldilocks" prompt. |
| `Prompt Perfecter` | Review and perfect prompts. |
| `Self-Perfecting Prompt Executor v2` | Execute a request with self-perfecting prompt execution. |
| `Skill Auditor` | Audit skills. |
| `Skill Engineer v7` | Create production-ready skills. |
| `Skill Perfecter` | Perfect skills. |
| `Summarize (pdf) v1` | Summarize a PDF for RAG. |
| `Takeaways (Notes) v5` | Extract takeaways from vault notes. |
| `WetHat Lab Assistant v3` | Create end-user documentation for the tss-tracker. |
| `Writing Assistant v1` | Take a sketch to a production-ready article. |

## Other Directories

- **`system-prompts/`** — Migrated custom system prompts, e.g. context-specific overrides for Obsidian-flavored Markdown and skill invocation syntax (`|>`).
- **`memory/`** — Saved memories (user identity, communication preferences) and summaries of recent conversations.
- **`copilot-conversations/`** — Archived agent conversations, indexed by `copilot-conversations.md`.

## License

[MIT](LICENSE) © 2026 Peter Ernst
