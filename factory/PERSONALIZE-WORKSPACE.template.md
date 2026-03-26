# PERSONALIZE-WORKSPACE.template.md

This template is for factory orchestration, not for the end operator.

It assumes the intake and transcript files have already been staged into `workspace/onboarding/`.

## Prompt

```text
Treat this as a tenant-personalization task for an existing sales-agent OpenClaw workspace.

You are not designing a new workspace from scratch.
You are personalizing an already-good preset.

First:
1. Read `AGENTS.md`
2. Read `SOUL.md`
3. Read `USER.md`
4. Read `TOOLS.md`
5. Read `MEMORY.md`
6. Read `IDENTITY.md`
7. Read `HEARTBEAT.md`
8. Read `MVP-DEFINITION.md`
9. Read `STARTER-PROMPTS.md`
10. Read `onboarding/intake.md` if it exists
11. Read `onboarding/transcript.md` if it exists

Your job is to personalize this workspace for the operator while preserving the base operating system already installed.

## What you should do

Use the staged onboarding material to update only the tenant-specific files:

- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- `IDENTITY.md`

You may also make a light update to:

- `HEARTBEAT.md`

Only if the onboarding material clearly supports it.

## What you should not change unless truly necessary

Do not rewrite the base operating system files unless the onboarding material clearly requires a small correction:

- `AGENTS.md`
- `SOUL.md`
- `MVP-DEFINITION.md`
- `STARTER-PROMPTS.md`
- workspace skills

Keep the core workflow grooves intact:

- opportunity intake
- follow-up drafting
- CRM note prep
- sales rhythm
- browser and portal support
- PDF form support

## Personalization rules

- Intake is the primary source of truth.
- Transcript can fill gaps, clarify style, and infer stable preferences.
- Do not invent secrets, passwords, MFA codes, tokens, or API keys.
- Do not hardcode browser state, auth state, or live credentials into workspace files.
- Do not overfit to one temporary conversation detail if it does not seem durable.
- Keep the operator-facing files concise and usable.
- Preserve approval boundaries.
- Preserve the default posture of drafting before acting.

## Missing information handling

If something important is missing, ask only the smallest number of focused follow-up questions needed to finish personalization well.

Do not ask for:

- raw passwords
- tokens
- MFA codes
- private keys

If a system or portal is mentioned but details are missing, record it in `TOOLS.md` as a setup note or credential slot instead of blocking the whole personalization pass.

## Output requirements

When done:

1. Update the relevant files in place.
2. Show the final contents of:
   - `USER.md`
   - `TOOLS.md`
   - `MEMORY.md`
   - `IDENTITY.md`
3. If you changed `HEARTBEAT.md`, show that too.
4. Briefly list any still-missing onboarding items as setup gaps, not as failures.
```
