---
name: agentmail
description: Send and receive email through AgentMail using AGENTMAIL_API_KEY and the local agentmail-cli helper.
requires:
  env:
    - AGENTMAIL_API_KEY
---

# AgentMail

This is a lightweight default capability wrapper for email work through AgentMail.

If the tenant later has a specific inbox workflow or message format, adapt to that instead of forcing these defaults.

Use AgentMail when email support is needed and `AGENTMAIL_API_KEY` is present.

Prefer `agentmail-cli` over handwritten curl unless you need an operation the helper does not expose yet.

Base URL:

```text
https://api.agentmail.to/v0
```

Authentication:

```text
Authorization: Bearer $AGENTMAIL_API_KEY
```

Common operations:

## Status

```bash
agentmail-cli status
```

## List inboxes

```bash
agentmail-cli list-inboxes
```

## Create an inbox

```bash
agentmail-cli create-inbox "Sales Assistant"
```

## List messages

```bash
agentmail-cli list-messages
```

## Send an email

```bash
agentmail-cli send recipient@example.com "Hello from the sales assistant" "This email was prepared by the sales assistant."
```

## Reply to a message

```bash
agentmail-cli reply MESSAGE_ID "Thanks for your email."
```

Raw API examples:

## List inboxes

```bash
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  https://api.agentmail.to/v0/inboxes
```

## Create an inbox

```bash
curl -s -X POST -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"display_name":"Sales Assistant"}' \
  https://api.agentmail.to/v0/inboxes
```

## Send an email

```bash
curl -s -X POST -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to":["recipient@example.com"],
    "subject":"Hello from the sales assistant",
    "text":"This email was prepared by the sales assistant."
  }' \
  https://api.agentmail.to/v0/inboxes/{inbox_id}/messages/send
```

## List messages

```bash
curl -s -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  https://api.agentmail.to/v0/inboxes/{inbox_id}/messages
```

## Reply to a message

```bash
curl -s -X POST -H "Authorization: Bearer $AGENTMAIL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text":"Thanks for your email."}' \
  https://api.agentmail.to/v0/inboxes/{inbox_id}/messages/{message_id}/reply
```

Required env:

- `AGENTMAIL_API_KEY`
- `AGENTMAIL_INBOX_ID` when a default inbox is already known

Never store the API key in workspace files. Keep it in the runtime environment or OpenClaw skill config.
