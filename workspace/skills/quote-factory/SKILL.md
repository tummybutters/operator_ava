---
name: quote-factory
description: Prepare quote-ready artifact plans, proposal structure, and output packaging for internet, UC, and comparison quotes.
---

# Quote Factory

This is a reusable quote workflow groove, not a rigid provider doctrine.

Use this skill when the operator needs:

- an internet quote
- a UC or phone-system quote
- a multi-provider comparison
- a revised quote pack
- a quote artifact cleaned up for delivery

## Core Contract

Default quote work should think in artifacts, not just text.

Each quote run should try to produce:

- `source`
  - the editable working file or canonical input
- `preview`
  - a textable or quickly reviewable artifact, usually PNG or short summary
- `final`
  - the client-ready PDF or final document
- `summary`
  - short operator-facing notes on what changed, what is missing, and what needs approval

## Default Workflow

1. Turn the request into a clean quote brief.
2. Identify quote type:
   - internet
   - UC / phones
   - bundled
   - comparison / revision
3. Identify required inputs:
   - customer or company
   - address or service location
   - user count / seat count
   - products requested
   - providers in play
   - blockers or missing data
4. Choose the lightest valid structure:
   - single-provider summary
   - side-by-side comparison
   - bundle proposal
5. Build or update the source artifact first.
6. Generate a preview artifact when helpful.
7. Generate the final artifact only after the content is stable enough to review.
8. Package output names, delivery notes, and filing notes.

## Structural Defaults

Use these as a starting point unless the tenant has a better house style:

- concise title and prepared-for block
- short scope or assumptions section
- provider or option sections
- pricing tables with recurring vs one-time charges clearly separated
- key inclusions / exclusions
- notes, caveats, or next steps

## Rules

- Do not invent pricing, contract terms, taxes, promos, or install fees.
- Distinguish clearly between:
  - known pricing
  - inferred structure
  - missing quote inputs
- Prefer a reusable shell over a one-off pretty document.
- Keep provider-specific defaults light unless the tenant has documented preferences.
- Default to a reviewable draft pack before external delivery.

## Default Output Pattern

```markdown
**Quote Pack**
- Type:
- Company:
- Need:
- Inputs confirmed:
- Inputs still needed:
- Source artifact:
- Preview artifact:
- Final artifact:
- Recommended next step:
- Approval needed:
```
