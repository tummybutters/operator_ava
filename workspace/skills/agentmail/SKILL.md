---
name: agentmail
description: Send and receive email through the AgentMail API using AGENTMAIL_API_KEY.
requires:
  env:
    - AGENTMAIL_API_KEY
---

# AgentMail

This is a lightweight default capability wrapper for email work through AgentMail.

If the tenant later has a specific inbox workflow or message format, adapt to that instead of forcing these defaults.

Use AgentMail when email support is needed and `AGENTMAIL_API_KEY` is present.

Base URL:

```text
https://api.agentmail.to/v0
```

Authentication:

```text
Authorization: Bearer $AGENTMAIL_API_KEY
```

Common operations:

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

Never store the API key in workspace files. Keep it in the runtime environment or OpenClaw skill config.
