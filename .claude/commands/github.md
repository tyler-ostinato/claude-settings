---
description: Stage safe files, create a feature branch, commit, push, and open a PR on GitHub.
---

You are helping the user ship their current changes to GitHub via a clean, safe PR workflow. Work through the steps below carefully and stop to confirm with the user before any action that could be destructive or expose sensitive data.

If a path was passed as an argument (`$ARGUMENTS`), treat it as the working directory for all git commands. Otherwise use the current directory.

---

## Step 1 — Check status and diff

Run these two commands in parallel:
- `git status` — to get the file list
- `git diff HEAD` — to see all changes (staged and unstaged)

Print the file list for the user. If the working tree is completely clean, stop and tell the user there is nothing to commit.

---

## Step 2 — Audit each file for safety

Classify every file by **filename only** into one of three buckets. Only read file contents if the filename is ambiguous (e.g. a file named `config` with no extension).

**SENSITIVE — must ask before staging:**
- `.env`, `.env.*`, `.envrc`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`
- Any filename containing: `secret`, `credential`, `password`, `token`, `apikey`, `api_key`
- `id_rsa`, `id_ed25519`, `id_dsa` (private SSH keys)
- `*.sqlite`, `*.db`, `*.sqlite3`, `*.log`

**NOISE — skip silently (do not stage):**
- `node_modules/`, `vendor/`, `.venv/`, `__pycache__/`, `*.pyc`
- `.DS_Store`, `Thumbs.db`
- `dist/`, `build/`, `target/`, `out/`, `.next/`, `.nuxt/`
- `coverage/`, `.nyc_output/`, `htmlcov/`
- `.gradle/`, `.idea/`, `.vscode/`

**SAFE — stage these:**
Everything else.

If any sensitive files are found, list them and ask: "These files look sensitive — should any be included? (y/N for each)". Wait for the answer before continuing.

If there are no safe files after filtering, stop and explain what was filtered and why.

---

## Step 3 — Stage and branch

Run these in sequence:

1. Stage each safe file **individually**: `git add <file>`. Never use `git add .` or `git add -A`.
2. Derive a branch name:
   - Format: `<type>/<short-description>` in kebab-case, ≤ 40 characters total
   - Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `ci`
   - If the branch already exists (`git branch --list <name>`), append `-2`
3. Create and switch: `git checkout -b <branch-name>`

After staging and branching, print a single summary line: `Staged N files → branch: <branch-name>`.

---

## Step 4 — Commit

Compose a Conventional Commits message using the diff from Step 1 (no need to re-read files):

```
<type>: <subject>     ← imperative mood, ≤72 chars, no period

<body>                ← optional bullet points explaining *why*, not *what*
```

Commit with `git commit -m "..."`. Do NOT use `--no-verify` or any hook-bypass flag. If a pre-commit hook fails, fix the issue and retry.

---

## Step 5 — Push and open PR

Run these in sequence:

1. `git push -u origin <branch-name>`
   - If rejected for any reason, stop and explain the error — do not force-push.
2. Detect the default branch: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || echo main`
3. Create the PR:

```
gh pr create --base <default-branch> --title "<commit subject>" --body "..."
```

PR body template:
```markdown
## Summary
<!-- 2–4 bullets: what changed and why -->

## Test plan
- [ ] Existing tests pass
- [ ] Manual smoke test performed
- [ ] New tests added (if applicable)
```

4. `gh pr view --web` to open it in the browser.

If `gh` is not installed or authenticated, print the remote URL and branch name and tell the user to open the PR manually.

---

## Guardrails (always enforce)

- Never use `--no-verify`, `--force`, `--force-with-lease`, or any hook-bypass flag
- Never commit directly to `main`, `master`, or `develop`
- Never stage files the user has said to skip
- If anything looks wrong or unclear, stop and ask rather than guessing
