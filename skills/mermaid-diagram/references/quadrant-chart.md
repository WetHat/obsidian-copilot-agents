# Quadrant Chart Reference

2×2 grid: plot items on two axes into four labeled quadrants.

## Minimal example

```mermaid
quadrantChart
    title Reach and engagement of campaigns
    x-axis Low Reach --> High Reach
    y-axis Low Engagement --> High Engagement
    quadrant-1 We should expand
    quadrant-2 Need to promote
    quadrant-3 Re-evaluate
    quadrant-4 May be improved
    Campaign A: [0.3, 0.6]
    Campaign B: [0.45, 0.23]
```

## Syntax

- `x-axis <left> --> <right>` — left required, right optional.
- `y-axis <bottom> --> <top>` — bottom required, top optional.
- `quadrant-1` top-right, `quadrant-2` top-left, `quadrant-3` bottom-left,
  `quadrant-4` bottom-right.
- Points: `Label: [x, y]` with x and y in range 0–1.

## Point styling

```mermaid
quadrantChart
    Point A: [0.9, 0.0] radius: 12
    Point B: [0.8, 0.1] color: #ff3300, radius: 10
    Point C: [0.7, 0.2] stroke-color: #10f0f0, stroke-width: 5px
```

## Notes
- Common use: prioritization (impact vs effort), risk matrices.
