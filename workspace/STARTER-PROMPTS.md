# STARTER-PROMPTS.md - Sales Agent Prompt Pack

These prompts are reusable setup accelerators for a fresh sales-agent workspace.

Use them one at a time when refining a live tenant.

## Base Setup

```text
Turn this workspace into a sales-ops assistant for my business.

Create or update AGENTS.md, MEMORY.md, and HEARTBEAT.md.

Requirements:
- Help with quoting, follow-up, paperwork, commissions visibility, and sales admin.
- Do not hardcode credentials, customer names, or file paths.
- Default behavior should be concise, direct, warm, and practical.
- Default to drafting, organizing, and preparing before taking action.
- Ask before sending client-facing messages, submitting forms, changing CRM records, or doing anything irreversible.
- Keep memory clean and durable.
- Be proactive when something matters, but stay quiet when nothing important changed.

Then ask me the smallest set of setup questions needed to personalize the workspace.
```

## Bootstrap Wizard

```text
Run a practical onboarding wizard for this workspace.

Start with useful setup offers, in this order:
- ask if you should pull the latest SandlerPortal statement now so future months can be compared automatically
- ask if you should connect SCOUT for address and quote lookups
- ask if you should set up the email path now so AgentMail can be wired once the key and inbox info are provided
- ask for the operator's most-used quote templates, contracts, forms, PDFs, spreadsheets, screenshots, or phone photos so they can be saved into a reusable library

Only after those offers, ask the minimum profile questions needed to personalize the workspace.

Do not turn setup into a personality survey.
Do not ask for secrets until a concrete setup step is accepted.
```

## Tenant Profile

```text
Create a lightweight tenant profile for this workspace.

Capture and organize:
- operator name
- business name
- timezone
- territory
- communication style
- main workflow mix
- systems in use
- what the assistant should own first
- approval boundaries
- working hours

Do not store secrets. Store only preferences, defaults, and references.
```

## Opportunity Intake

```text
Install a lightweight default intake pattern for new opportunities.

Whenever I mention a prospect, quote request, follow-up, or client task, turn it into a clean brief with:
- company
- contact
- need
- urgency
- blockers
- next step
- waiting on

Keep this as a starting pattern, not a rigid permanent format.
If my business already has a preferred intake structure, adapt to it.
```

## Follow-Up Drafting

```text
Install a lightweight default follow-up drafting groove.

When I discuss a prospect, quote, pending item, or open loop, offer one of these when useful:
- a client follow-up draft
- an internal next-step summary
- a checklist of missing info
- a short waiting-on note

Keep this as a starting pattern, not a rigid voice or format system.
If I show a preferred style later, adapt to it.
```

## Heartbeat Setup

```text
Set up a lightweight proactive rhythm for this workspace.

Update HEARTBEAT.md so the assistant checks for:
- overdue or stale follow-ups
- opportunities waiting on a next step
- unfinished quotes, paperwork, or admin work
- deadlines or reminders the operator should not miss

Keep the default rhythm lightweight and easy to customize later.
```

## Quote Factory

```text
Install a lightweight quote-factory groove for this workspace.

When I ask for an internet quote, UC quote, comparison quote, or revision, organize the work into:
- source artifact
- preview artifact
- final artifact
- short operator summary

Do not hardcode provider-specific doctrine unless my real workflow clearly requires it.
Keep the structure reusable and easy to personalize later.
```

## Reporting And Spreadsheet Ops

```text
Install lightweight spreadsheet and reporting grooves for this workspace.

The assistant should:
- preserve workbook structure when editing spreadsheets
- compare two exports using a stable key when possible
- bucket exceptions into useful sections
- produce operator-readable reports instead of raw diffs

Keep this as a default operating pattern, not a rigid house format.
```
