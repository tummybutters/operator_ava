---
name: spreadsheet-ops
description: Safely create, update, compare, and summarize spreadsheet artifacts while preserving workbook structure and formatting.
---

# Spreadsheet Ops

Use this skill when the operator needs help with:

- editing an existing workbook
- generating a clean pricing sheet
- comparing two exports
- preserving formatting while updating values
- turning raw sheet data into an operator-facing workbook

## Default Posture

Treat spreadsheets as working artifacts, not plain tables.

Prefer:

- preserving sheet names
- preserving formulas when possible
- preserving widths, fills, borders, and freeze panes
- writing outputs to a new file when risk is non-trivial

## Default Workflow

1. Identify the artifact type:
   - source workbook
   - export to compare
   - report to generate
   - tracker to update
2. Clarify the stable key or row-matching rule if comparison is involved.
3. Inspect workbook structure before editing:
   - sheet names
   - key columns
   - formulas
   - formatting that matters
4. Make the smallest safe change.
5. Prefer creating a new output workbook when:
   - comparison logic is complex
   - formulas may break
   - the original is a template or system export
6. Summarize what changed and what still needs review.

## Good Defaults

- Use sectioned worksheets for ops reports.
- Auto-size columns where reasonable.
- Freeze panes for reference sheets and larger reports.
- Keep sheet names short and stable.
- Surface unmatched or ambiguous rows in their own review section.

## Rules

- Do not silently destroy formulas or formatting.
- Do not overwrite a source workbook unless the task clearly calls for it.
- If row matching is fuzzy, say so and create a review bucket.
- Prefer operator-readable output over clever but opaque transformations.

## Default Output Pattern

```markdown
**Spreadsheet Work**
- Source file:
- Output file:
- Workbook type:
- Matching rule:
- Changes made:
- Review bucket:
- Recommended next step:
```
