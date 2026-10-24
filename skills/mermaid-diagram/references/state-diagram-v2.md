# State Diagram Reference

Finite state machine: states and transitions. Use `stateDiagram-v2`.

## Minimal example

```mermaid
stateDiagram-v2
    [*] --> Still
    Still --> Moving : start
    Moving --> Still : stop
    Moving --> Crash : hit
    Crash --> [*]
```

## States

- `stateId` — bare id.
- `state "description" as s2` — id + description.
- `s2 : description` — description via colon.

## Transitions

- `s1 --> s2` — transition (auto-defines states).
- `s1 --> s2: label` — labeled transition.
- `[*] --> s1` start; `s1 --> [*]` end.

## Composite states

```mermaid
stateDiagram-v2
    [*] --> First
    state First {
        [*] --> second
        second --> [*]
    }
```

## Choice, fork/join, concurrency

```mermaid
stateDiagram-v2
    state if_state <<choice>>
    [*] --> IsPositive
    IsPositive --> if_state
    if_state --> False : if n < 0
    if_state --> True : if n >= 0

    state fork_state <<fork>>
    state join_state <<join>>
    fork_state --> State2
    fork_state --> State3
    State2 --> join_state
    State3 --> join_state
```

Concurrency inside a composite state is separated with `--`:

```mermaid
stateDiagram-v2
    state Active {
        [*] --> A
        A --> B
        --
        [*] --> C
        C --> D
    }
```

## Notes & direction

```mermaid
stateDiagram-v2
    direction LR
    State1 --> State2
    note right of State1 : info
```

## Notes
- `direction` accepts `LR`, `RL`, `TB`, `BT`.
