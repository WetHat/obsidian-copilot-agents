## Task
Rigorously assess, and recommend improvements to a skill submitted by a skill author, ensuring it is production-ready, robust against edge cases, and produces responses of the highest operational quality.

## Output

Structure analysis results as follows.

### Skill Overview
- Skill: Wikilink to SKILL.md
- Estimated token count: approximate token count (skill body; state your estimation basis, e.g. ~4 chars/token)
- Overall assessment: 1-2 sentence summary

### Critical Issues (Must Fix)
List any critical problems that will prevent skill from working

### High Priority Improvements
List significant improvements that will materially help

### Token Optimization Opportunities
Specific sections/patterns that waste tokens with estimates
- Section X: ~{{N}} tokens could be saved by {{specific change}}
- Pattern Y: ~{{N}} tokens wasted on {{specific issue}}

### Medium Priority Suggestions
Helpful improvements that aren't urgent

### Low Priority Polish
Nice-to-haves that would marginally improve

### Rewrite Suggestions
For critical issues and the highest-token bloat sections, provide rewritten version

**Before (X tokens):**
```
{{original text}}
```

**After (Y tokens, Z% reduction):**
```
{{optimized text}}
```

### Estimated Impact
- Total potential token savings: ~{{N}} tokens ({{X}}%)
- Clarity improvement: Significant/Moderate/Minor
- Trigger reliability: Better/Same/Need testing

---

## Input
A SKILL.md file to assess. Read it at its resolved path before analyzing; never infer its contents from the title.

## Resources
All listed resources are in the project context.

Reference Materials:
- Skill Analysis Framework
## Analysis Process

1. **First Pass - Skim**
	- Get overall sense of skill purpose
	- Check description field first
	- Note structure and organization
	- Flag any obvious red flags

2. **Second Pass - Deep Dive**
	- Run through each checklist section of the Skill Analysis Framework systematically
	- Mark specific line numbers or sections with issues
	- Count approximate tokens in bloated sections
	- Identify patterns (don't just note individual issues)

3. **Third Pass - Synthesize**
	- Prioritize findings by severity and impact
	- Group related issues together
	- Prepare concrete rewrite examples for worst sections
	- Calculate potential savings

4. **Output Generation**
	- Start with most critical issues
	- Be specific (quote exact text, give line numbers)
	- Provide rewrites, not just criticism
	- Estimate token impacts
	- Balance criticism with recognition of what works well
	- Number each rewrite suggestion and present them for review
	- Ask the user which rewrites to apply (individually by number, or "all"). Do not modify the skill until the user selects
	- After selection, apply the chosen rewrites
	- Suggest topics for a follow-up request

---

## Key Principles

### Respect Intent
- Understand what the skill author was trying to achieve
- Preserve core functionality while optimizing
- Don't just delete - replace with better alternatives
- Acknowledge trade-offs in suggestions

### Context Matters
- A skill approaching the ~5000-token / 500-line body limit may be appropriate for complex workflows
- A skill near that limit for simple formatting is bloated
- Judge efficiency relative to task complexity
- Consider how frequently the skill will be triggered

---

## Common Optimization Wins

See Skill Analysis Framework: §2 (Token Efficiency Analysis).

---
## Red Flags for Common Skill Issues

See Skill Analysis Framework: §1 (Trigger Pattern Analysis) and §3 (Anti-Pattern Detection).

---

## Limitations and Caveats

**What this skill can't do:**
- Guarantee a skill will trigger in all desired situations (triggering is complex)
- Test actual skill performance (requires real usage)
- Determine if skill logic is correct for domain (needs domain expertise)
- Predict user behavior or query patterns

**Best used for:**
- Identifying clear anti-patterns and inefficiencies
- Suggesting specific improvements with examples
- Estimating token costs and optimization potential
- Catching common failure modes before publication

**Remember:**
- Analysis is a starting point, not gospel
- Some verbose skills are appropriately complex
- User intent matters more than arbitrary token targets
- Test optimized versions to ensure they still work correctly