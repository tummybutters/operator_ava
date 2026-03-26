# Factory Flow

This folder is for tenant creation and cloud-workspace personalization.

The intended flow is:

1. Create a tenant project from the preset.
2. Apply the preset into a writable cloud workspace.
3. Stage intake and transcript files into `workspace/onboarding/`.
4. Ask the cloud agent to read `onboarding/PERSONALIZE-WORKSPACE.md` and execute it.

This keeps the base preset stable while letting an AI agent do the final tenant shaping inside the live workspace.

Useful handoff docs:

- `OPERATOR-AGENT-BRIEF.md`
- `NEW-AGENT-HANDOFF.md`
