# Gantt Chart Reference

Schedule over time: tasks with durations, dates, dependencies, milestones.

## Minimal example

```mermaid
gantt
    title A Gantt Diagram
    dateFormat YYYY-MM-DD
    section Section A
        A task          :a1, 2014-01-01, 30d
        Another task    :after a1, 20d
    section Section B
        Task in Another :2014-01-12, 12d
        another task    :24d
```

## Task syntax

`Task title :<tags>, <id>, <start>, <end|length>`

- Tags (optional, first): `done`, `active`, `crit`, `milestone`.
- Metadata items comma-separated; forms:
  - `<end>` — runs to that date/duration.
  - `<start>, <end|length>` — explicit start.
  - `after <taskId>, <end|length>` — start after task ends.
  - `<id>, <start>, <end|length>` — with reference id.
- `until <taskId>` — end at the referenced task's start.

Durations use `ms`, `s`, `m`, `h`, `d`, `w`, `M` (month), `y`.

## Sections & exclusions

```mermaid
gantt
    dateFormat  YYYY-MM-DD
    excludes    weekends
    section Dev
      Implement :done, des1, 2014-01-06, 3d
    section Docs
      Write docs :active, a1, after des1, 3d
```

## Milestones & markers

```mermaid
gantt
    dateFormat HH:mm
    axisFormat %H:%M
    Initial milestone : milestone, m1, 17:49, 2m
    Task A : 10m
    Final vert : vert, v1, 17:58, 1m
```

## Date / axis formats

- `dateFormat` — input dates (default `YYYY-MM-DD`).
- `axisFormat` — output labels (e.g. `%Y-%m-%d`, `%H:%M`).

## Notes
- Tasks are sequential by default; start defaults to the previous task's end.
