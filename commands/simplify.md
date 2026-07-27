---
description: Review a file for clarity and token efficiency, then rewrite it in place.
---

Review and rewrite the file at `$ARGUMENTS` for clarity and token efficiency. If no argument is given, ask the user which file to simplify.

---

## Step 1 — Read the file

Read the full contents and identify waste:

- **Redundant prose** — sentences that restate what a command or heading already says
- **Implied instructions** — things like "wait for the answer before continuing" that any reader would assume
- **Over-explained commands** — inline explanations of self-evident shell commands
- **Unnecessary structure** — steps that exist solely to hold a single line and could merge with a neighboring step
- **Verbose phrasing** — multi-word phrases where one word works (`in order to` → `to`, `run these in sequence` → remove it)

---

## Step 2 — Rewrite

Produce a rewritten version that:
- Preserves every behavioral rule and guardrail exactly
- Removes or merges content identified in Step 1
- Keeps all lists, code blocks, and heading structure that aid scannability
- Does not add new content, features, or commentary

---

## Step 3 — Show a diff summary and confirm

Before writing, print:
- Original line count vs. new line count
- A brief bullet list of what was removed or merged (one line per change)

Ask: "Apply this rewrite? (y/N)"

If the user confirms, overwrite the file. Otherwise discard and explain what to adjust.
