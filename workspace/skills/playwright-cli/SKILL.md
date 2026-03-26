---
name: playwright-cli
description: Use the local playwright-cli binary for browser navigation, portal inspection, screenshots, and draft form work.
---

# Playwright CLI

Use `playwright-cli` for browser and portal tasks.

Before first use in a session:

```bash
which playwright-cli
playwright-cli --help
```

Preferred uses:

- open a portal
- inspect page state
- take screenshots
- gather status or pricing information
- draft field input
- verify whether a workflow is blocked by auth or MFA

Do not do these without approval:

- final form submission
- external sends
- account changes
- purchases
- deletions
- contract execution

Useful commands:

```bash
playwright-cli open https://example.com
playwright-cli snapshot
playwright-cli screenshot
playwright-cli fill <ref> "<text>"
playwright-cli click <ref>
playwright-cli close-all
```
