---
name: data-compare-reporting
description: Compare exports, bucket exceptions, and produce concise operator-facing reports instead of raw diffs.
---

# Data Compare Reporting

Use this skill for:

- comparing monthly or weekly exports
- finding missing, new, or changed records
- building exception-first summaries
- creating an ops report from messy source data

## Default Philosophy

Do not stop at “here is the diff.”

Try to produce:

- a stable comparison key
- exception buckets
- a short summary
- a review queue for ambiguous rows

## Default Buckets

Use only the buckets that fit the task:

- missing this period
- new this period
- materially changed
- uncategorized / needs review
- one-time or special items

## Default Workflow

1. Define the comparison units and stable key.
2. Normalize each dataset enough to compare safely.
3. Compare using the clearest rule available.
4. Bucket exceptions into operator-readable sections.
5. Quantify changes when useful.
6. Emit a clean summary plus an output artifact if needed.

## Rules

- Be explicit when matching rules are imperfect.
- Prefer exception-first reporting over giant raw dumps.
- If the source data is messy, keep a separate review bucket.
- Do not infer business meaning when the evidence is weak.

## Default Output Pattern

```markdown
**Comparison Report**
- Source A:
- Source B:
- Comparison key:
- Missing:
- New:
- Materially changed:
- Review bucket:
- Output artifact:
- Recommended next step:
```
