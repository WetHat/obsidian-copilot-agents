# XY Chart Reference

Bar and line charts for numeric data over x/y axes.

## Minimal example

```mermaid
xychart
    title "Sales Revenue"
    x-axis [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
    y-axis "Revenue (in $)" 4000 --> 11000
    bar [5000, 6000, 7500, 8200, 9500, 10500, 11000, 10200, 9200, 8500, 7000, 6000]
    line [5000, 6000, 7500, 8200, 9500, 10500, 11000, 10200, 9200, 8500, 7000, 6000]
```

## Syntax

- `xychart` keyword; `xychart horizontal` for horizontal orientation.
- `title "text"` — optional.
- x-axis categorical: `x-axis [cat1, "cat with space", cat3]`.
- x-axis numeric: `x-axis title min --> max`.
- y-axis numeric: `y-axis title min --> max` (or `y-axis title` to auto-range).
- `bar [values]` and `line [values]` — one or more series, all numeric.

## Simplest

```mermaid
xychart
    line [+1.3, .6, 2.4, -.34]
```

## Notes
- Quotes only required for multi-word text.
- Config: `showDataLabel: true` shows bar values; `showDataLabelOutsideBar`
  moves them outside.
- Per-point labels on lines: `line [25 "Launch", 45, 72]`.
