---
name: sandler-statements
description: Pull monthly statement data from SandlerPortal, save a dated snapshot, and compare month-over-month changes.
---

# Sandler Statements

Use this skill for:

- logging into SandlerPortal and pulling statement data fast
- saving a month's statements as structured JSON
- comparing two monthly snapshots for new, removed, and changed lines

## Fast Path

Do not start with generic browser probing.

If the operator asks for statement data, go straight to the script:

```bash
node skills/sandler-statements/pull.js YYYY-MM --email "..." --password "..."
```

If the operator already provided credentials in the current request, use them directly.

If the operator did not provide credentials, try these env vars before asking:

- `SANDLER_PORTAL_EMAIL`
- `SANDLER_PORTAL_PASSWORD`

## Data Storage

Monthly snapshots live in:

```text
data/statements/YYYY-MM.json
```

Comparison reports live beside them:

```text
data/statements/compare-YYYY-MM-vs-YYYY-MM.md
```

## Pull Workflow

1. Run `node skills/sandler-statements/pull.js ...`.
2. Let the script log in, go to Statements, paginate, and save the snapshot.
3. Report:
   - item count
   - total net billed
   - total commission
   - output file path

## Comparison Workflow

When asked to compare months:

```bash
node skills/sandler-statements/compare.js 2026-04 2026-03
```

Then summarize:

- new this month
- removed this month
- commission changes
- net billed changes
- biggest movers

## Rules

- Ask before irreversible portal submissions or account changes.
- Portal login, navigation, statement viewing, and CSV/export retrieval are approved when the operator explicitly asks for statement work.
- Prefer the script over ad hoc Playwright exploration.
- Prefer Export CSV if it works. If not, the table scrape is acceptable.
- Store money as numbers, not strings with `$` or commas.
- Compare lines using a stable service-ish key built from customer, provider, account number, address, provider identifier, product, and commission type.
