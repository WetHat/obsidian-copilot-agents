# Block Diagram Reference

High-level system/architecture/process overview with author-controlled grid
layout (blocks + connectors), not auto-layout.

## Minimal example

```mermaid
block
    columns 3
    a b c d
```

## Columns & composite blocks

```mermaid
block
    columns 2
    a["A label"] b:2
    block:group1
      columns 1
      x y z
    end
    space
    a --> b
```

- `columns N` — set column count; blocks wrap to the next row.
- `id:width` — span multiple columns (e.g. `b:2`).
- `block:id` … `end` — composite (nested) block.
- `space` / `space:N` — intentional gap (1 column default, or N columns).

## Block shapes

| Syntax | Shape |
| --- | --- |
| `id["text"]` | rectangle |
| `id("text")` | round-edged |
| `id(["text"])` | stadium |
| `id[["text"]]` | subroutine |
| `id[("text")]` | cylinder |
| `id(("text"))` | circle |
| `id((("text")))` | double circle |
| `id>text]` | asymmetric |
| `id{"text"}` | rhombus |
| `id{{"text"}}` | hexagon |
| `id[/"text"/]` | parallelogram |

Block arrows and space blocks:

```mermaid
block
    a space b
    blockArrowId<["Label"]>(right)
    down<[" "]>(down)
```

Arrow directions: `right`, `left`, `up`, `down`, `x`, `y`.

## Edges & styling

```mermaid
block
    A space B
    A-- "X" -->B
    style A fill:#636,stroke:#333
    classDef blue fill:#6e6ce6
    class A blue
```

## Notes
- You control placement explicitly via columns, widths, and `space`; this is
  the main reason to choose `block` over `flowchart`.
