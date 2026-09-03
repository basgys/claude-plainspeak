# sanity

A Claude Code `Stop` hook that gatekeeps every assistant reply on two independent axes before it reaches you:

- **style** — mechanical AI-writing tells: banned vocabulary, templated phrasing, rule-of-three filler, hollow significance framing, copula avoidance
- **cognitive_load** — buried lede, ambiguous outcome signaling, fake due diligence, exhaustive tradeoff narrative in place of a decision

## How it works

1. **Regex pass** (free, instant). A small hard-banned word list blocks on any occurrence; a larger "AI vocabulary" list only flags on repeat use in the same message, since a single ordinary use of a word like "highlight" isn't a violation — the tell is repetition, not presence. Fenced code blocks and blockquotes are stripped before matching, so anything the assistant is quoting verbatim (file contents, error output, another person's words) is never judged.
2. **Haiku fallback** (only runs if the regex pass is clean). A stateless, one-shot `claude --restricted --model haiku -p` classification judging sentence structure against both axes, with a confidence split: `VIOLATION` blocks and forces a rewrite, `NOTE` surfaces as a non-blocking message for you to judge yourself. `--restricted` means this sub-invocation loads no settings/hooks, so it can't recursively trigger itself.

The rules it enforces are pulled from a CLAUDE.md-style writing-rules doc — edit `hooks/sanity.sh` to match your own.

## Install

As a plugin (recommended):

```
/plugin marketplace add basgys/claude-sanity
/plugin install sanity@claude-sanity
```

Or manually: copy `hooks/sanity.sh` to `~/.claude/hooks/`, `chmod +x` it, and merge this into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [ { "type": "command", "command": "~/.claude/hooks/sanity.sh", "timeout": 30 } ] }
    ]
  }
}
```

## Requirements

`claude` CLI on PATH, `jq`, standard POSIX `grep`/`awk`.
