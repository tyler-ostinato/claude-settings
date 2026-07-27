---
description: Initialize a new git repo in a directory and push it to GitHub as a new remote repository.
---

Initialize a GitHub repo from a local directory. Use `$ARGUMENTS` as the target directory, or the current directory if omitted. Stop and confirm before any destructive or sensitive action.

---

## Step 1 — Inspect the directory

Run in parallel:
- `ls -la <dir>`
- `git -C <dir> rev-parse --is-inside-work-tree 2>/dev/null`

Stop if: the directory doesn't exist, or it's already a git repo with an `origin` remote.

If it's not yet a git repo, run `git -C <dir> init`.

---

## Step 2 — Confirm repo name and visibility

Derive a name from the directory basename in lowercase kebab-case (e.g. `MyApp` → `my-app`). Ask:

1. "Repo name: `<name>` — press Enter to accept or type a different name."
2. "Public or private? (default: private)"

Wait for answers before continuing.

---

## Step 3 — Audit files

Run `git -C <dir> status --short`. Classify by filename only (read contents only if ambiguous).

**SENSITIVE — ask before staging:**
- `.env`, `.env.*`, `.envrc`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`
- Names containing: `secret`, `credential`, `password`, `token`, `apikey`, `api_key`
- `id_rsa`, `id_ed25519`, `id_dsa`
- `*.sqlite`, `*.db`, `*.sqlite3`, `*.log`

**NOISE — skip silently:**
- `.claude/`
- `node_modules/`, `vendor/`, `.venv/`, `__pycache__/`, `*.pyc`
- `.DS_Store`, `Thumbs.db`
- `dist/`, `build/`, `target/`, `out/`, `.next/`, `.nuxt/`
- `coverage/`, `.nyc_output/`, `htmlcov/`
- `.gradle/`, `.idea/`, `.vscode/`

**SAFE — stage these:** everything else.

For each sensitive file found, ask whether to include it. If no safe files remain, ask whether to proceed with an empty initial commit or stop.

---

## Step 4 — Add .gitignore if missing

If no `.gitignore` exists, ask: "No .gitignore found — create one? If so, what language/framework? (Enter to skip)"

If provided, write a minimal `.gitignore` for that stack and stage it.

---

## Step 5 — Stage and commit

1. Stage each safe file individually: `git -C <dir> add <file>`. Never use `git add .` or `-A`.
2. Commit: `git -C <dir> commit -m "chore: initial commit"`. Never use `--no-verify`.

---

## Step 6 — Create repo and push

```
gh repo create <repo-name> --<public|private> --source <dir> --remote origin --push
```

- If `gh` is missing or unauthenticated, tell the user to run `gh auth login` and retry.
- If the name is taken, suggest `<repo-name>-2` and confirm before retrying.

On success, run `gh repo view --web` to open it in the browser.

---

## Guardrails

- Never use `--no-verify`, `--force`, or any hook-bypass flag
- Never stage files the user said to skip
- Never overwrite an existing remote without explicit confirmation
- When in doubt, stop and ask
