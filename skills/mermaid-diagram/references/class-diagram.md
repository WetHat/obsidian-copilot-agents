# Class Diagram Reference

UML static structure: classes, attributes, methods, and their relationships.

## Minimal example

```mermaid
classDiagram
    Animal <|-- Duck
    Animal : +int age
    Animal : +mate()
    class Duck{
        +String beakColor
        +swim()
    }
```

## Defining classes

- `class Animal` — explicit.
- `Vehicle <|-- Car` — implicit via relationship.
- `class Animal["Label"]` — label.

## Members

Via `:` (one at a time) or `{}` (grouped). Methods are distinguished by `()`.

```mermaid
classDiagram
    class BankAccount {
        +String owner
        +deposit(amount) bool
    }
```

## Visibility & modifiers

- `+` public, `-` private, `#` protected, `~` package/internal.
- Method suffix `*` abstract, `$` static; field suffix `$` static.
- Return type: space after `()` then type, e.g. `getPoints() List~int~`.
- Generics use `~Type~`.

## Relationships

| Syntax | Meaning |
| --- | --- |
| `<|--` | inheritance |
| `*--` | composition |
| `o--` | aggregation |
| `-->` | association |
| `--` | link (solid) |
| `..>` | dependency |
| `..|>` | realization |
| `..` | link (dashed) |

Cardinality on association ends: `Customer "1" --> "*" Ticket`.

## Annotations & namespaces

```mermaid
classDiagram
    class Shape <<interface>>
    namespace Company.Engineering {
        class Developer
    }
```

## Notes
- Class names: alphanumeric + underscore/dash. Use backticks for special chars:
  `` class `Car Class!` ``.
