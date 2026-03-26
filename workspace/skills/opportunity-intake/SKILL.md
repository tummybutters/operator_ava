---
name: opportunity-intake
description: Convert messy inbound sales work into a concise structured brief with clear next steps.
---

# Opportunity Intake

This is a default starting pattern, not a rigid forever template.

If the tenant already has a preferred intake format, use that instead.

Use this skill whenever the operator mentions:

- a new prospect
- a quote request
- a renewal
- a provider issue
- a customer problem
- a paperwork task
- a portal-related task

By default, turn the request into a concise brief with these fields:

- company
- contact
- need
- urgency
- blockers
- next step
- waiting on

## Rules

- Keep briefs short and practical.
- Infer obvious structure when possible.
- Ask follow-up questions only when missing information materially affects the work.
- Do not invent pricing, commitments, status, or deadlines.
- Treat this as an internal operating format unless explicitly told to turn it into an external draft.
- If the operator later shows a preferred structure, mirror that and stop forcing this default.

## Default Output Pattern

```markdown
**Opportunity Brief**
- Company:
- Contact:
- Need:
- Urgency:
- Blockers:
- Next step:
- Waiting on:
```
