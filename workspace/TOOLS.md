# TOOLS.md - Local Setup Notes

This file is for setup-specific operational notes, not for granting permissions.

Do not store raw passwords, tokens, or secrets here.

Store references, labels, expectations, and setup notes only.

## Messaging

- Primary channel: {{primary_channel}}
- Channel label or account name: {{channel_label}}
- Secondary channels: {{secondary_channels}}
- Channel status: {{channel_status}}

## Email

- Inbox layer: {{email_layer}}
- Inbox label: {{email_label}}
- Email workflow notes: {{email_notes}}

## Google Workspace

- Workspace usage: {{google_workspace_usage}}
- Primary Google surfaces: {{google_workspace_surfaces}}
- Auth status: {{google_workspace_auth_status}}
- GWS notes: {{google_workspace_notes}}

## CRM

- Primary CRM: {{crm}}
- CRM notes: {{crm_notes}}

## Storage

- Storage home: {{storage_system}}
- Filing notes: {{storage_notes}}

## Portals

- Approved portals: {{approved_portals}}
- Portal workflow notes: {{portal_notes}}

## Document Tools

- PDF / e-sign stack: {{document_tools}}

## Voice And Media

- Telephony layer: {{telephony_layer}}
- Media tooling notes: {{media_tooling_notes}}

## CLI Stack

- `openclaw`
- `playwright-cli`
- `gws`
- `twilio`
- `ngrok`
- `gh`
- `gh-copilot` (optional)
- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`
- `blender` (optional)
- `opencli` (environment-specific)

## Credential Slots

- Messaging channel: {{channel_secret_ref}}
- Email layer: {{email_secret_ref}}
- Google Workspace: {{google_workspace_secret_ref}}
- Telephony / Twilio: {{telephony_secret_ref}}
- CRM: {{crm_secret_ref}}
- Portal credentials: {{portal_secret_refs}}
- Document tools: {{document_tool_secret_ref}}

## Notes For Future Onboarding

- Fill live credentials during onboarding, not in git.
- Prefer repeatable setup over one-off machine edits.
- Record labels, secret refs, and expected login flow here. Keep raw secrets elsewhere.
- Capture deeper workflow preferences here only after the tenant actually shows them.
