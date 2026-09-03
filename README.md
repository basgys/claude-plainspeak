# nospin

Two Claude Code hooks that gatekeep AI-writing tells and cognitive-load problems before they reach you — in chat replies, and in PR descriptions.

- **style** — mechanical AI-writing tells: banned vocabulary, templated phrasing, rule-of-three filler, hollow significance framing, copula avoidance, hidden-verb nominalization
- **cognitive_load** — six general principles (point first, context before ask, clean structure, say only what's warranted, respect working-memory limits, unambiguous terminal state), grounded in BLUF, SBAR, the Minto Pyramid Principle, Cowan (2001) on working memory, and the Federal Plain Language Guidelines
- **pr_structure** (PR hook only) — prose not bullets, motivation before implementation, no test-plan section unless asked, treats the PR as one unit

## How it works

Two-stage check, both hooks:

1. **Regex pass** (free, instant). A small hard-banned word list blocks on any occurrence; a larger "AI vocabulary" list only flags on repeat use in the same message, since a single ordinary use of a word like "highlight" isn't a violation — the tell is repetition, not presence. Also catches sentence-length (~40 words, splitting on `;` too) and flat-list-length (~10 items) ceilings mechanically. Fenced code is stripped before matching; blockquotes are NOT stripped — testing found that exemption was a full bypass (any leading `>` line dodged both stages, both via deliberate gaming and natural blockquote-formatting habit), so quoted content is now judged like anything else.
2. **Haiku fallback** (only runs if the regex pass is clean). A stateless, one-shot `claude --restricted --model haiku -p` classification against the axes above, with a confidence split: `VIOLATION` blocks and forces a rewrite, `NOTE` surfaces as a non-blocking message for you to judge yourself. `--restricted` means this sub-invocation loads no settings/hooks, so it can't recursively trigger itself.

Both hooks cap retries at 3 attempts, surfacing each attempt via a `systemMessage`, and give up gracefully (letting the message through) rather than looping forever.

Rules are grounded in a CLAUDE.md-style writing-rules doc and evidence-based communication research — edit `hooks/sanity.sh` (chat replies, `Stop` hook) and `hooks/pr-check.sh` (`gh pr create`/`gh pr edit --body`, `PreToolUse`/`Bash` hook) to match your own.

## Install

As a plugin (recommended):

```
/plugin marketplace add basgys/claude-nospin
/plugin install nospin@claude-nospin
```

Or manually: copy both scripts under `hooks/` to `~/.claude/hooks/`, `chmod +x` them, and merge this into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "~/.claude/hooks/sanity.sh", "timeout": 30 } ] }
    ],
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "~/.claude/hooks/pr-check.sh", "timeout": 30 } ] }
    ]
  }
}
```

## Requirements

`claude` CLI on PATH, `jq`, standard POSIX `grep`/`awk`. `pr-check.sh` also needs `shasum`.
