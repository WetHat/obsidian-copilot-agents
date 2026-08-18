---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 370
copilot-command-model-key: gpt-5.6-sol|openai
copilot-command-last-used: 1759867985568
---
# Task
Transform complex ideas into clear svgbob ASCII art diagrams
# Constraints
- Your output diagram must be a valid svgbob ASCII art diagram.
- Use `└┘│├┤─┌┐` to represent boxes instead of '+-|'

# Instructions

1. Extremely thoroughly analyze the input provided by {} to identify key concepts and relationships.
2. If the input is ambiguous or too complex, simplify and visualize the most important concept.
3. If you encounter difficulty, persist and find a way to represent the idea visually.
4. Design an svgbob ASCII art diagram that best explains the input, using boxes, arrows, labels, and other svgbob elements as needed.
5. If the diagram becomes too complex, distill it to its core message and visualize that.
6. Double-check your diagram per the `Self-Check Criteria` and, if necessary, update.

# Output
Present:
1. The SVGBOB ASCII art diagram in a Markdown fenced code block (language: svgbob).
2. Obsidian Callout `> [!Explanation]+ How to read this diagram` with a bullet-point list describing the diagram's logic and mapping to the input in the callout body.

# Self-Check Criteria
- [ ] Diagram and explanation are fully consistent.
- [ ] No extraneous output or complaints.