# Cycle 5 F1 — Secret-scan note

## What happened
- A former ElevenLabs key (value redacted here) was hardcoded in 8 promo scripts plus
  `tutorial/project.md`, committed in v1.4.0 public history.
- Worktree copies are now env-only via `tutorial/elevenlabs_key.py`
  (`ELEVENLABS_API_KEY` → `API_KEY` → legacy `~/video-use/.env` fallback).

## What history cannot fix here
- The key remains in git history (`4edd567` era). Do **not** attempt
  `filter-branch`/`filter-repo` from this agent — the repo is public and
  the key must be treated as compromised.

## Required owner action (outside code)
1. Rotate/revoke the key in the ElevenLabs dashboard.
2. Update the local-only `~/video-use/.env` and env vars.
3. Never paste the new key into the repo, issues, or chat logs.

## Gate
- `python tutorial/check_no_secrets.py` — exit 0 = clean worktree.
- Suggested push-agent step before every push: run the gate; block on
  any `sk_…` / `ghp_…` / `xox…` hit in tracked worktree files.
