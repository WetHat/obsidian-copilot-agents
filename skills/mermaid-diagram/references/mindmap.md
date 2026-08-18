# Mindmap Reference

Hierarchical tree radiating from one central concept. Indentation defines depth.

## Minimal example

```mermaid
mindmap
  root((mindmap))
    Origins
      Long history
    Research
      On effectiveness
    Tools
      Pen and paper
      Mermaid
```

## Node shapes

| Syntax | Shape |
| --- | --- |
| `id[text]` | square |
| `id(text)` | rounded square |
| `id((text))` | circle |
| `id))text((` | bang |
| `id)text(` | cloud |
| `id{{text}}` | hexagon |
| plain text | default shape |

## Icons & classes

```mermaid
mindmap
    Root
        A
        ::icon(fa fa-book)
        B(B)
        :::urgent large
```

## Markdown strings

```mermaid
mindmap
    id1["`**Bold** and *italics*`"]
      id2[Regular label]
```

## Notes
- Relative indentation (not absolute) determines hierarchy.
- Optional `layout: tidy-tree` via frontmatter for a tidy tree layout.
