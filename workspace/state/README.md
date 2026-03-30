# Tenant State

This directory is the machine-readable state layer shared between the live OpenClaw tenant and the Vercel dashboard.

Use markdown files in the workspace for long-form reasoning and operator guidance.

Use the JSON files here for live UI state that should stay synchronized across the assistant and dashboard.

## Files

- `tasks.json`
  - shared task list
  - assistant should usually ask before adding inferred tasks
  - when a task is fully complete, the assistant should say so and remove it

- `today.json`
  - daily summary for the current calendar day in the tenant timezone
  - should reflect meaningful work completed, important progress, and near-term next steps

- `business.json`
  - stable tenant facts for the Business tab
  - approved portals, systems, auth readiness, channel status, and operator profile

- `workflows.json`
  - lightweight workflow/readiness view for the dashboard
  - keep this simple and factual

## Rules

- Keep the JSON valid.
- Keep fields concise and UI-friendly.
- Do not store raw secrets, passwords, MFA codes, or tokens here.
- Prefer updating these files after meaningful work rather than letting the dashboard infer state from chat.
- The dashboard should render these files directly when present.
