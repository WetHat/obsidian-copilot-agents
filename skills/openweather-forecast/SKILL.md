---
name: openweather-forecast
description: Witty/funny weather forecast for a given location, using the local OpenWeatherMap MCP server (Docker MCP Toolkit). Use when the user asks about weather, forecast, temperature, rain, whether to take an umbrella, or today/tomorrow/weekend conditions — or explicitly asks for the OpenWeatherMap MCP server. Not for historical weather or climate data.
metadata:
  copilot-enabled-agents: codex,opencode
---

# OpenWeatherMap forecast

## Getting the data

Call the `docker-mcp_weather` tool first — never skip straight to the CLI.
No third-party weather sites, no external API keys.

- `city`: location in English, ASCII only (München → `Munich`,
  Köln → `Cologne`, Zürich → `Zurich`). If the user doesn't name a
  location, use Sindelfingen.
- `units`: `c`
- `lang`: `en` — keep fixed; condition parsing and severity tie-breaks
  depend on English strings

### CLI fallback — only after a failed tool call

Use this only when the in-session route is unavailable or the call itself
errors. Docker Desktop must be running; the `openweather` server lives in the
`obsidian` MCP profile. `--gateway-arg=--profile=...` requires the MCP
profiles feature; if the flag is rejected, enable it once with
`docker mcp feature enable profiles`.

On Windows (PowerShell):

```powershell
docker mcp tools call weather "city=<City>" units=c lang=en --gateway-arg=--profile=obsidian
```

On macOS/Linux the same command works without quoting changes.


### Failure handling
If both routes fail (`unknown tool`, docker daemon down,
Docker Desktop not running): report the problem plainly and stop. Only use a
different weather source if the user explicitly agrees — do not silently
substitute.

## Reading the output

The tool prints two text blocks:

- `Current weather for <city>:` — `Conditions`, `Now`, `High`, `Low`,
  `Pressure`, `Humidity`, `FeelsLike`, `Wind Speed`, `Wind Degree` (degrees;
  convert to compass), `Sunrise`/`Sunset` (Unix timestamps)
- `Weather Forecast for <city>:` — repeated 3-hour entries, each with
  `Date & Time` (UTC), `Conditions` (`Category description`), `Temp`,
  `High`, `Low` — pool only `Temp`; ignore `High`/`Low`

Convert forecast timestamps to the forecast location's local time (use
Europe/Berlin for the user's home region). Group entries per local day,
then split each day into
three 8-hour spans — `00h–08h`, `08h–16h`, `16h–24h` local — and pool each span's
`Temp` values and conditions. For every span derive:

- Temp: the min–max range of the span's `Temp` values, rounded to whole
  degrees Celsius (a single value when the range collapses)
- Condition: the most frequent condition in the span; break ties toward the
  more severe one (thunderstorm/squall/tornado > snow/sleet > rain >
  drizzle > fog/mist/haze/ash/dust/smoke/sand > clouds > clear)

A span with no data gets `—`. The server does **not** return precipitation
amounts or probabilities, forecast wind, UV, or cloud-cover percentages —
never mention them.

## Deliverables

Structure (keep it tight — this is a performance, not a report):

1. A punchy one-liner verdict on the overall trend.
2. **Right now:** temp, feels-like, conditions, wind, humidity — one sentence, already
   cracking a joke about it.
3. **The days ahead for `<city>`:** one GitHub-flavored markdown table — one row per local
   day, three 8-hour-span columns, every cell `Temp, condition`. Weekday +
   date in the first column, spans are local time. Follow the table with one
   or two short quips about the data (rain = wet sun, heat =
   outdoor sauna, clear sky = magic perfection, etc.) — the day's
   personality comes straight from its row.

   Table shape (values illustrative):

   ```markdown
   | Date | 00h–08h | 08h–16h | 16h–24h |
   | --- | --- | --- | --- |
   | Thu, Sep 3 | 14–16 °C, light rain | 18–21 °C, broken clouds | 15–17 °C, clear sky |
   | Fri, Sep 4 | 12 °C, few clouds | 19–24 °C, clear sky | 16–18 °C, few clouds |
   ```
4. A closing quip or practical nudge (umbrella, sunscreen, denial — whichever
   the data supports).

Tone rules:

- Casual, warm, self-aware; a slightly dramatic TV meteorologist who has
  accepted their fate. Humor must be **derived from the real numbers** — joke
  about 30 °C, not about fictional storms.
- Stay factually accurate: ranges, conditions, and warnings come strictly from
  the tool output. Humor never overrides data.
- If any span holds thunderstorm, snow, or a max of 30 °C or higher, drop
  the sass for that item and state it clearly first.
