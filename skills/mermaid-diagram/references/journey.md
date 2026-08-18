# User Journey Reference

High-level steps actors take to complete a task, scored for sentiment.

## Minimal example

```mermaid
journey
    title My working day
    section Go to work
      Make tea: 5: Me
      Go upstairs: 3: Me
      Do work: 1: Me, Cat
    section Go home
      Go downstairs: 5: Me
      Sit down: 5: Me
```

## Syntax

- `title <text>` — optional title.
- `section <name>` — groups tasks.
- Task: `Task name: <score>: <comma-separated actors>`.
- Score is an integer 1–5 (5 = best).

## Notes
- Actors are arbitrary names; multiple actors comma-separated.
- One or more tasks per section.
