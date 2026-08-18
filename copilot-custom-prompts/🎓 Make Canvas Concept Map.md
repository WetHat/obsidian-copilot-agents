---
copilot-command-context-menu-enabled: false
copilot-command-slash-enabled: true
copilot-command-context-menu-order: 250
copilot-command-model-key: gpt-5.6-terra|openai
copilot-command-last-used: 1761306472014
---
## Task
Transform supplied technical/academic material into a concept map rendered as Obsidian Canvas (JSON).

## Context
- [[Obsidian Canvas Schema]]

## Objectives
- The CMAP should visually organize key points, ideas, concepts, and their relationships to enhance clarity and accessibility.
- Relationships (edges) between **text nodes** and **group nodes** should be clearly labeled, and hierarchies or groupings (**group nodes**) should be visually distinct.
- Flag relationships requiring human verification by setting the edge color to `#ff0000`
- Flag implied relationships by setting the edge color to `#00ffff`

## Constraints
- Do not invent concepts, events, or relationships not present in the source. If unsure, flag instead of guessing
- The generated CMAP nodes and edges must strictly adhere to the `Obsidian Canvas Schema`
- Maintain a formal, precise, and informative tone
- Ensure each relationship is represented by a single, clearly labeled edge in the CMAP
- If a text node lies inside a group’s bounding box, do not create **text node ↔ group node** relationships
- Canvas layout constraints:
	- Minimize edge/edge and edge/node intersections.
	- Cluster related concepts to indicate relationship strength.
	- Avoid node/node overlaps; space nodes for readability.
	- Ensure each node’s connection point (top/right/bottom/left) has only incoming or outgoing edges, not both.

## Instructions
Follow the instructions step-by-step:
1. Think hard and accurately identify and extract key concepts (including persons, organizations, events, resources, etc.) and relationships from the content provided by {}.
2. Extract explicit relationships mentioned in the source content and assign concise, action-oriented labels (for example, “leads to,” “supports,” “results in”).
3. Infer implied relationships beyond direct citations such as:
	- Causal (e.g., PolicyChange --"results in"--> BehavioralShift)
	- Temporal (e.g., ProposalDrafted --"precedes"--> ReviewProcess)
	- Hierarchical (e.g., Department --"contains"--> Team)
	- Motivational/Functional (e.g., UserFeedback --"informs"--> DesignIteration)
4. Include a brief summary (text node; 2-3 sentences; color: `#ffff00`) at the top of the diagram that explains the main structure and highlights key connections.
5. Present the CMAP as Obsidian Canvas (fenced JSON code block) for easy drop-in.

---

## Example Output
```json
{
	"nodes":[
		{"id":"ad1777d7ca3ede41","type":"group","x":-620,"y":-360,"width":290,"height":300,"label":"Group 1"},
		{"id":"2960f6aff1ddee35","type":"group","x":-140,"y":-360,"width":290,"height":300,"label":"Group 2"},
		{"id":"b250e16f1ba2fa84","type":"text","text":"Concept 1","x":-600,"y":-340,"width":250,"height":60},
		{"id":"0006accb426cec46","type":"text","text":"Concept 2","x":-600,"y":-140,"width":250,"height":60},
		{"id":"baae8265fc824fea","type":"text","text":"Concept 3","x":-120,"y":-340,"width":250,"height":60},
		{"id":"3fbb892e55587f9a","type":"text","text":"Concept 4","x":-120,"y":-140,"width":250,"height":60},
		{"id":"125c2a6506752459","x":-370,"y":-480,"width":250,"height":60,"color":"#ffff00","type":"text","text":"Summary"}
	],
	"edges":[
		{"id":"7398f724b9a4c139","fromNode":"b250e16f1ba2fa84","fromSide":"bottom","toNode":"0006accb426cec46","toSide":"top","color":"#ff0000","label":"depends on"},
		{"id":"400ab1e631512373","fromNode":"baae8265fc824fea","fromSide":"bottom","toNode":"3fbb892e55587f9a","toSide":"top","label":"supports"},
		{"id":"d23cb54cf2e17c87","fromNode":"ad1777d7ca3ede41","fromSide":"right","toNode":"2960f6aff1ddee35","toSide":"left","color":"#00ffff","label":"precedes"}
	]
}
```
