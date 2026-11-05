# Railroad Diagram Reference

Grammar/syntax diagrams: grammar rules rendered as railroad tracks. Mermaid
supports four notation-specific keywords; ABNF is covered in full below, with
the deltas for the other notations.

## Keywords

| Notation            | Keyword               | Rule assignment          |
| ------------------- | --------------------- | ------------------------ |
| ABNF (RFC 5234)     | `railroad-abnf-beta`  | `name = definition ;`    |
| EBNF (W3C/ISO)      | `railroad-ebnf-beta`  | `name = definition ;` or `::=` |
| PEG                 | `railroad-peg-beta`   | `Name <- definition ;`   |
| IR primitives       | `railroad-beta`       | `name = expression ;`    |

All four are beta: the `-beta` suffix is required.

## Minimal example (ABNF)

```mermaid
railroad-abnf-beta
title "Email Address"
address = local-part "@" domain ;
local-part = 1*( ALPHA / DIGIT / "." / "-" ) ;
domain = label *( "." label ) ;
label = 1*( ALPHA / DIGIT / "-" ) ;
```

## Common structure

- Diagram-type keyword on the first line.
- Optional `title "..."`.
- Optional `accTitle: ...` and `accDescr: ...` accessibility lines.
- One grammar rule per statement; every rule ends with `;`.
- Rule names are non-terminals; quoted strings are terminals.
- Pick one notation per diagram and use its matching keyword.

## ABNF syntax (`railroad-abnf-beta`)

- Alternation: `/` — `A / B`.
- Concatenation: whitespace — `A B`.
- Repetition prefixes:
  - `*A` — zero or more;
  - `1*A` — one or more;
  - `2*4A` — between two and four;
  - `3A` — exactly three.
- Grouping: `( A B )`; optional group: `[ A ]`.
- Terminals: quoted strings (`"text"`) or numeric values (`%x41`, `%d65`,
  `%b1000001`), including ranges such as `%x30-39`.
- Comments start with `;` and run to the end of the line.
- Core rules such as `ALPHA` and `DIGIT` may be referenced without defining
  them.

## Other notations

**EBNF (`railroad-ebnf-beta`)** — `=` or `::=` assignment; sequence `A B`
(W3C) or `A , B` (ISO 14977); choice `|`; optional `A?` (W3C) or `[ A ]`
(ISO); repetition `A*` / `A+` (W3C) or `{ A }` (ISO); grouping `( ... )`;
comments `/* ... */` (W3C) or `(* ... *)` (ISO); special sequence `? text ?`;
exception `A - B`.

**PEG (`railroad-peg-beta`)** — `<-` assignment; ordered choice `/`; sequence
by whitespace; suffix `?`, `*`, `+`; prefix predicates `&A` (and) and `!A`
(not); `.` matches any character; comments start with `#`.

**IR primitives (`railroad-beta`)** — constructors: `terminal("text")`,
`nonterminal("name")`, `sequence(a, b, ...)`, `choice(a, b, ...)`,
`optional(a)`, `zeroOrMore(a)`, `oneOrMore(a)`, `special("text")`.

## Notes
- End every rule with `;`; a missing terminator breaks the diagram.
- Put comments on their own line rather than after a rule, where the `;`
  terminator makes the intent ambiguous.
- Break complex grammars into small, reusable rules and reference them by name.
- Use `title` to name the grammar being documented.
- The hand-drawn look (`look: handDrawn`) is not supported for railroad
  diagrams.
- Requires Mermaid v11.16.0+.
