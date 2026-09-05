# Plainspeak

If you also juggle with multiple agents and can't stand their fluff, negative parallelisms (This is not a skill, it's a plugin!), and other tics, then this plugin is meant for you and your sanity. 

```
Great question! Let me delve into the nuances here.
Two different results found, and one matters.
Two things I should flag rather than let stand.
Four options, and one of them is already measured and free.
```

Plainspeak is a Claude Code plugin that detects typical LLMs tics and sentences that are hard to parse and blocks them from you. The plugin blocks the answer and requests the agent to rewrite it with up to 5 attempts. A green, yellow, or red emoji is displayed to easily spot which part to read.

```
/plugin marketplace add basgys/claude-plainspeak
/plugin install plainspeak@claude-plainspeak
```

## Requirements

- `jq`, POSIX `grep`/`awk`/`sed`
- `python3`, for `hooks/metrics.py`
- `shasum`, used by `pr-check.sh` only

`lib.sh` silently skips the Python stage when `python3` is missing. The bash
checks still run. These three are lost:

- negative parallelism
- the significance-coda two-clause test
- the unnamed-referent check

Negative parallelism is the strongest check in the suite, so install
`python3`.

To wire it up by hand instead of through `/plugin`: copy `hooks/` to
`~/.claude/hooks/`, `chmod +x` the scripts, and merge `hooks/hooks.json` into
`~/.claude/settings.json` with `${CLAUDE_PLUGIN_ROOT}` replaced by
`~/.claude`.

## Customising

The rules are one person's taste. Edit `hooks/lib.sh` for the shared word
lists and patterns, `hooks/style-rules.sh` for the text injected before each
reply, and `hooks/pr-check.sh` for the PR-specific title and body rules.

## Under the hood

Shared checks live in `hooks/lib.sh` and run on both surfaces:

- **banned words**: an explicit list, blocking on any occurrence
- **repeated AI-vocab**: a wider list that flags on the second use, since
  one "showcase" is ordinary and repetition is the tell
- **templated phrasing**: not-X-but-Y, throat-clearing, hollow significance
- **negative parallelism**: stating what is untrue right after what is
- **significance coda**: a verbless fragment, then a clause whose only job
  is to say the fragment was important
- **unnamed referent**: a sentence that says something is valuable and ends
  before naming it
- **counted ceilings**: 40 words per sentence, 10 items per flat list, an
  em dash budget, five figures per prose paragraph

`hooks/metrics.py` carries the shapes needing a count or a two-clause test;
bash regex carries the literal forms. Fenced code is exempt. Blockquotes and
tables are judged like any other prose.

`pr-check.sh` adds title rules (Conventional Commits, 72-char cap,
imperative mood, one change per title, no issue ref GitHub already renders)
and body rules (no "Changes made" section, no test-plan boilerplate, no
unfalsifiable claims, no all-bullet changelog). Titles too generic to find
later by search are rejected against [Google's CL-description
guide](https://google.github.io/eng-practices/review/developer/cl-descriptions.html):
"Fix bug", "Fix build", "Phase 1", "Add convenience functions".

## Benchmarks

| result | source |
|---|---|
| framing the rules as an accessibility requirement cut the block rate from 48% to 34% (p=0.004) | `docs/prompt-framing.md` |
| threatening the model moved nothing: 47% against 48%, p=0.89 | `docs/prompt-framing.md` |
| the local checks catch 95% of what two independent judges agree on, at 90% precision | `docs/judge-benchmark.md` |
| a full check costs ~250ms, against 27-79s for the model judge that was removed | `docs/judge-benchmark.md` |
| negative parallelism separates AI prose from human kernel commits 83:1 at a 1% false-positive rate | `docs/judge-benchmark.md` |

The honest limit: of the messages that pass every local check, roughly a
fifth are still consensus violations. They are mostly cognitive-load items,
because no regex sees a buried finding.
