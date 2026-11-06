---
name: model-name
description: >-
  Return the model that executes the current OpenCode session, resolved from
  OPENCODE_SESSION_ID. Use when the caller needs the executing model's name;
  the skill does not read or modify any note.
metadata:
  copilot-enabled-agents: opencode
---

# Model Name

Return the model that executes this skill. The script queries the OpenCode
session database and prints the model of the session's latest assistant
message. It knows nothing about notes, paths, or frontmatter; the caller
decides what to do with the result.

## Input

None. The executing session comes from `OPENCODE_SESSION_ID`.

## Requirements

- PowerShell 7.4 or later on .NET 8+ (the script uses
  `Microsoft.Data.Sqlite`, which targets .NET 8+).
- The `Microsoft.Data.Sqlite` and `SQLitePCLRaw` packages in the NuGet cache.
  The script loads them directly; no Python or other helper is required.

## Process

1. Run the launcher:
   ```powershell
   & "<skill folder>/scripts/model-name.cmd"
   ```
2. Check the result before returning it. Exit `0` with output matching
   `## Output` → continue. Non-zero exit or unmatched output → the cause is
   on stderr or in the raw output; report it per `## Contingencies` and stop.
3. Return the script's stdout verbatim to the caller. Do not edit notes, set
   properties, parse the model, or infer a note path.

## Output

The script prints one line, `model: <reportedModel>`, or one JSON object with
`-Json`:

- `model` — exact session model identifier, for example
  `deepseek/deepseek-v4.1-flash-1017`.
- `modelShort` — provider prefix stripped, for example
  `deepseek-v4.1-flash-1017`.
- `reportedModel` — the value selected by `-ShortModelName`; equals `model`
  by default.
- `provider`, `variant` — route and effort variant from the session.
- `sessionId`, `sessionTitle`, `sessionCreatedAt` — the executing session and
  when it was created.
- `sessionUpdatedAt` — when the session row was last written.
- `modelSource`, `confidence`, `modelResolvedAt` — where the model came from:
  `modelSource` is `latest-assistant`, `latest-model-switch`, or
  `session-default`; `confidence` is `exact` or `session-default`.
- All values are strings or `null`. `provider`, `variant`, and `sessionTitle`
  are `null` when unset; timestamps are `null` when the stored time is zero.

## Options

- `-ShortModelName` — report `modelShort` instead of the exact model ID.
- `-SessionId <id>` — inspect a known session instead of
  `OPENCODE_SESSION_ID`.
- `-Database <path>` — override the OpenCode database path.
- `-SqliteRoot <path>` — override the NuGet package root that holds
  `Microsoft.Data.Sqlite` and `SQLitePCLRaw`.

## Installation

If the script reports that `Microsoft.Data.Sqlite` is missing, ask for approval to install it with
the .NET SDK:

```powershell
$dir = Join-Path $env:TEMP 'model-name-sqlite'
dotnet new console -o $dir --force
dotnet add $dir package Microsoft.Data.Sqlite
Remove-Item $dir -Recurse -Force
```

The packages land in `%USERPROFILE%\.nuget\packages`. Use `-SqliteRoot` to
point at a different NuGet package root.

## Contingencies

- `OPENCODE_SESSION_ID` missing → report that the session is unknown and stop;
  do not guess a model.
- `Microsoft.Data.Sqlite` missing → the script prints installation instructions
  and exits 1; forward them and stop.
- OpenCode database missing → report the expected path and stop.
- Session not found → report the session ID and stop.
- No model recorded → report the session and stop.
- Unsupported schema → report the SQLite error and stop; do not fall back to
  timestamp heuristics.

## Resources

- `scripts/model-name.ps1` — session lookup, `Microsoft.Data.Sqlite` loading,
  the read-only SQLite query, and formatting.
- `scripts/model-name.cmd` — Windows launcher; requires PowerShell 7 (`pwsh`).
