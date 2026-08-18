# Sequence Diagram Reference

Interaction diagram showing how processes/actors exchange messages and in what
order.

## Minimal example

```mermaid
sequenceDiagram
    participant A as Alice
    participant B as Bob
    A->>B: Hello Bob
    B-->>A: Hi Alice
```

## Participants

- `participant Name` — rectangle actor
- `actor Name` — stick-figure actor
- `participant A as Full Name` — alias
- Optional types: `participant A@{ "type": "database" }` (also `boundary`,
  `control`, `entity`, `collections`, `queue`).

## Messages / arrows

| Syntax | Meaning |
| --- | --- |
| `A->B: msg` | solid line, no arrowhead |
| `A-->B: msg` | dotted line, no arrowhead |
| `A->>B: msg` | solid line, arrowhead |
| `A-->>B: msg` | dotted line, arrowhead |
| `A-xB: msg` | solid line, cross |
| `A--xB: msg` | dotted line, cross |
| `A-)B: msg` | solid line, open arrow (async) |
| `A--)B: msg` | dotted line, open arrow (async) |

## Blocks

```mermaid
sequenceDiagram
    A->>B: request
    alt success
        B-->>A: ok
    else failure
        B-->>A: error
    end
    opt optional path
        A->>B: maybe
    end
    loop every minute
        B-->>B: poll
    end
    par parallel 1
        A->>B: one
    and parallel 2
        A->>C: two
    end
```

## Notes, activation, numbering

```mermaid
sequenceDiagram
    autonumber
    Note right of A: text on the right
    Note over A,B: spanning note
    A->>+B: start
    B-->>-A: end
```

## Notes
- `activate A` / `deactivate A` or the `+` / `-` arrow suffix show lifelines.
- `box` … `end` groups participants vertically.
