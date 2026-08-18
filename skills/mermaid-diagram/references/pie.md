# Pie Chart Reference

Part-to-whole breakdown as proportional slices.

## Minimal example

```mermaid
pie title Pets adopted by volunteers
    "Dogs" : 386
    "Cats" : 85
    "Rats" : 15
```

## Syntax

- `pie` keyword; optional `showData` to render values after labels.
- Optional `title <text>`.
- Slices: `"label" : positiveValue` (values up to two decimals, > 0).

```mermaid
pie showData
    title Key elements
    "Calcium" : 42.96
    "Iron" : 5
```

## Notes
- Values must be positive numbers; negative values error.
- Optional config: `donutHole` (0–0.9) renders a donut, `legendPosition`,
  `highlightSlice`.
