---
name: gws-meta-workflows
description: Use the Google Workspace CLI for multi-step Gmail, Calendar, Drive, Docs, and Sheets workflows without browser automation.
---

# GWS Meta-Workflows

Use this skill when Google Workspace is part of the operator's workflow and the `gws` CLI is installed and authenticated.

This is the preferred path over browser automation for Gmail, Calendar, Drive, Docs, and Sheets when structured CLI access is available.

## Requirements

- `gws` installed
- authenticated Google Workspace session
- relevant scopes for the workflow

Recommended auth flow:

```bash
gws auth setup
gws auth login -s drive,gmail,calendar,docs,sheets
gws auth status
```

## Why Use This

- structured JSON output
- less fragile than browser automation
- clearer audit trail of what the agent actually did
- better fit for repeatable inbox, calendar, docs, and drive operations

## Default Use Cases

Use `gws` for lightweight, structured Google Workspace work such as:

- Gmail triage and draft preparation
- calendar lookup and meeting prep
- Drive and Docs retrieval
- Sheets lookup or light update work
- scheduling checks and availability lookups

If a tenant later has deeper Google-specific workflows, add them through onboarding instead of hardcoding them here.

Example:

```bash
gws gmail +triage --max 10 --format json
```

## Rules

- Prefer `gws` over browser automation when both can do the job.
- Keep approval boundaries for sends, deletes, invites, and sharing changes.
- Use JSON output when available.
- If auth or scope errors appear, report exactly what is missing.
- Do not store tokens or raw Google credentials in workspace files.
