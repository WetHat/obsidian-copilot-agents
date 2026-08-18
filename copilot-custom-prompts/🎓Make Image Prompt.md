---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 330
copilot-command-model-key: z-ai/glm-5.2|openrouterai
copilot-command-last-used: 1780830219170
---
# Task
Transform the provided content into a single, high-impact image-generation prompt for an AI image tool.

# Inputs
- Content: {}
- Style reference: [[Image Styles]]

# Procedure
1. If the content is missing, too vague, or does not provide enough detail to identify a clear theme and at least one relevant visual cue, ask exactly one clarifying question and stop.
2. The clarifying question must include 1-3 numbered options labeled 1., 2., 3. and a final "Other (please specify)" option.
3. Otherwise, choose one style from the table that best matches the content's theme and mood.
4. Write exactly one richly detailed final prompt that begins with "Generate an image" and translates the main theme, tone, and key concepts into visually distinctive imagery and symbolism rather than repeating the source wording verbatim.

# Grounding rules
- Use only information supported by the provided content and the style table.
- Do not invent named entities, settings, numbers, backstory, or other specifics.
- Keep the prompt appropriate for a broad audience and avoid inappropriate, misleading, or untrustworthy elements.

# Output contract
- Output only a single plain-text prompt.
- If clarifying, output only the question.
- If drafting the image prompt, include the selected style, the scene, the key elements, the mood, and any relevant context.
- Do not add explanations, labels, bullets, or other formatting.