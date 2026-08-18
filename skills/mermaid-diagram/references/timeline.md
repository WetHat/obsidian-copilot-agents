# Timeline Reference

Chronology of time periods mapped to events, optionally grouped into sections.

## Minimal example

```mermaid
timeline
    title History of Social Media
    2002 : LinkedIn
    2004 : Facebook : Google
    2005 : YouTube
    2006 : Twitter
```

## Syntax

- `timeline` keyword; optional `title <text>`.
- `{time period} : {event}` — one event per period.
- Multiple events: `{period} : {event1} : {event2}` or a bare `: {event}` on
  following lines.
- Both period and event are plain text (not limited to numbers).

## Sections / ages

```mermaid
timeline
    title Industrial Revolution
    section 17th-20th century
        Industry 1.0 : Machinery, Water power
        Industry 2.0 : Electricity, Mass production
    section 21st century
        Industry 4.0 : Internet, Robotics
```

## Direction

`timeline LR` (default) or `timeline TD` (top-down).

## Notes
- First period renders leftmost; first event of a period renders topmost.
- Use `<br>` to force a line break.
