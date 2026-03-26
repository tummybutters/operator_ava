---
name: twilio-cli
description: Use the Twilio CLI for SMS, voice, phone number management, and Twilio API workflows instead of browser automation.
---

# Twilio CLI

This is a lightweight default capability wrapper for Twilio.

If the tenant later has a specific telephony workflow, webhook pattern, or approval process, adapt to that instead of forcing these defaults.

Use this skill when Twilio is part of the operator's workflow and the `twilio` CLI is installed and authenticated.

This is the preferred path over browser automation for Twilio console work when the CLI can do the job.

## Authentication

```bash
twilio login
twilio profiles:list
twilio profiles:use <profile-name>
```

## Best Practices

- Always use E.164 phone number format.
- Prefer `--output json` for machine-readable results.
- Keep sends, calls, purchases, and webhook changes approval-gated unless explicitly authorized.
- Use Twilio debugger logs when something fails.
- Do not store raw account credentials in workspace files.

## Common Commands

### SMS

```bash
twilio api:core:messages:create --from "+1XXXXXXXXXX" --to "+1YYYYYYYYYY" --body "Hello"
twilio api:core:messages:list --limit 10 --output json
twilio api:core:messages:fetch --sid SMXXXXXXXX --output json
```

### Calls

```bash
twilio api:core:calls:create --from "+1XXXXXXXXXX" --to "+1YYYYYYYYYY" --url "http://demo.twilio.com/docs/voice.xml"
twilio api:core:calls:list --limit 10 --output json
```

### Phone Numbers

```bash
twilio phone-numbers:list
twilio phone-numbers:buy:local --area-code 415
twilio phone-numbers:update PNXXXXXXXX --sms-url https://example.com/webhook
```

### Debugging

```bash
twilio debugger:logs:list --limit 20
```

## Usage Rules

- Prefer preparation and inspection before action.
- Ask before sending SMS, placing calls, buying numbers, changing phone number configuration, or deploying public webhooks.
- If telephony work is approved, keep the resulting notes clean and paste-ready for the operator.
