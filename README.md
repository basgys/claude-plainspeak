# plainspeak

Assistant replies come back padded. You have probably scrolled past these in
your own transcripts:

```
It's not a config problem, it's a caching problem.   (nobody raised config)
Great question! Let me delve into the nuances here.
This underscores the importance of a robust approach.
...and the answer, four paragraphs down, in a 55-word sentence.
```

plainspeak is a Claude Code plugin that keeps them out of your chat replies
and PR descriptions. It sends the writing rules ahead of every reply so the
first draft passes, then reads the finished reply and blocks it for a rewrite
when it does not, quoting the exact text that failed. It does the same to a
PR title and body before `gh pr create` runs. Every check is local and takes
about 250ms.

```
/plugin marketplace add basgys/claude-plainspeak
/plugin install plainspeak@claude-plainspeak
```

## The three hooks

| hook | event | what it does |
|---|---|---|
| `style-rules.sh` | `UserPromptSubmit` | injects the writing rules before the reply is drafted |
| `sanity.sh` | `Stop` | checks the finished reply, blocks and asks for a rewrite |
| `pr-check.sh` | `PreToolUse`/`Bash` | checks `gh pr` titles and bodies before the command runs |

A hook cannot retract a message already displayed, so every block leaves a
discarded draft in the transcript. That is why the rules go out first.

## What gets checked

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

## The rewrite loop

Every check runs before either hook blocks, so one verdict lists every flag.
Telling a writer about one violation at a time spends an attempt per rule.

Each flag quotes the text that fired it. A rewrite tripping the identical
flag is told so, and the instructions tighten as attempts climb: free
editing, then literal substring edits only, then a hard length cap.

Both hooks allow 5 attempts, then give up and let the message through. Each
attempt prints a `systemMessage` under the draft it judged, so you scroll
for the green tick and read only that one.

## What was measured

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

## Research tooling

`tools/` and `judge/rubric.txt` reproduce the numbers in `docs/`. `mine.py`
extracts a corpus from local transcripts, `sample.py` draws a stratified
sample, `redact.py` strips identifiers before anything leaves the machine,
and `label.sh` / `judge_openai.sh` run the two judges. None of it runs at
runtime.
