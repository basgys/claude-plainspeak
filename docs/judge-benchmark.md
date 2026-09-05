# Judge benchmark

Which model should judge writing quality, and whether a model is needed
at all. Both hooks now answer the second question with no; see Status.

## Results

Agreement with `gpt-5.6-terra` as reference judge, on one shared sample of
300 real assistant messages, all judges reading the same rubric.

| judge | style flags | kappa vs Terra | agreement | s/message | n |
|---|---|---|---|---|---|
| gpt-5.6-terra | 68% | reference | reference | 7.4 | 300 |
| **gpt-5.6-luna** | **67%** | **0.71** | 87% | 10.9 | 300 |
| claude-haiku-4.5 | 50% | 0.29 | 64% | 63 | 121 |
| claude-sonnet | 7% | -0.02 | 43% | 28 | 30 |

Cognitive-load axis: Luna 0.65, Haiku 0.22.

Sonnet at three effort levels, 40 messages each, showing effort does not
move leniency:

| effort | wall (P=10) | style flags | cog flags |
|---|---|---|---|
| low | 19s | 6/40 | 7/40 |
| medium | 30s | 1/40 | 2/40 |
| high | 65s | 2/40 | 6/40 |

### What the numbers say

**The rubric is well specified.** Two OpenAI models of very different sizes
land on kappa 0.71 with near-identical flag rates (67% vs 68%). An
ambiguous rubric would not produce that.

**The Claude models are lenient on it,** and more so as they get larger.
Haiku flags half of what Terra flags; Sonnet flags a tenth. The
disagreement is one-directional: on the Haiku-vs-Terra comparison, Terra
alone flagged 38 style violations against 5 the other way. Reading those
38, they are predominantly negative parallelism that Haiku let through:

```
"not cron — unattended runs keep web's injection surface out"
"so they anchor at the epoch instead of pinning to the floor forever"
"— not authoritative, not newly stale"
"confirmed across community sources, not Bright Data's own docs"
```

**Luna beats Haiku on every axis measured here:** agreement with a frontier
judge, catching the target constructions, and speed (6x).

### Decision

Luna was rejected on privacy: it would send every assistant message to a
third party on every turn. `tools/redact.py` exists and would have to move
into the hook and be trusted continuously.

Haiku was then removed outright, since the Python metrics reached 95%
recall and the remote call was buying 5% for a minute of waiting.

Revisit if an Anthropic model measures above kappa 0.6 on this protocol,
or the privacy tradeoff changes.

## Status

Neither hook calls a model. Once the Python metrics absorbed
negative parallelism they caught 95% of what the two judges agree on, at
90% precision, in ~250ms rather than 27-79 seconds.

Cost of the removal, on the same 300 labelled messages: of the 80 that
pass every fast check, 16 are still consensus violations, so about a fifth
of the clean-looking band ships unjudged. Those are predominantly
cognitive-load items no regex sees.

`judge/rubric.txt` keeps the rubric, so this protocol still runs and the
model judge can be reinstated by measurement.

`hooks/pr-check.sh` dropped its classifier too. The judgments it made and
no regex replaces: whether the body length suits the diff, whether the
approach's shortcomings are named, whether the reasoning survives a dead
link. Its mechanizable rules moved into the local checks.

## Protocol

Reproducible from a clean checkout. Every number above came from these
steps.

### 1. Build the corpus

```
python3 tools/mine.py corpus.json
```

Extracts assistant text blocks from `~/.claude/projects/**/*.jsonl`,
strips fenced code the way the hook does, keeps blocks of 15+ words.
Yielded 3,209 messages and 373,211 words.

### 2. Draw one shared sample

```
python3 tools/sample.py corpus.json 300 sample.json sample-redacted.json \
  -- <project terms to redact>
```

Stratified across the stage 1.5 metric signal (0 to 3+ checks tripped), so
the sample is not swamped by the short clean messages that dominate the
corpus. Writes the sample twice, raw and redacted, in the same order.

**Every judge must see the same messages in the same order.** A
disagreement between misaligned samples means nothing.

### 3. Run each judge

```
JUDGE_MODEL=haiku PLAINSPEAK_NOSTRAT=1 \
  tools/label.sh sample.json haiku.jsonl 300 12

OPENAI_API_KEY=... OPENAI_MODEL=gpt-5.6-terra \
  tools/judge_openai.sh sample-redacted.json terra.jsonl 300 8
```

Both scripts read the rubric from `judge/rubric.txt`, so every judge
answers the same question. That file was the Stop hook's stage 2 prompt
before the model call was removed.

`JUDGE_EFFORT` sets `--effort` on the Claude side.

### 4. Score

Cohen's kappa per axis, plus raw agreement and flag rates. Claude rows
carry no index, and `xargs -P` writes out of order, so they are realigned
by an exact match on the stage 1.5 metric vector.

### Rules

- **Redact before anything leaves the machine.** `tools/redact.py` replaces
  emails, URLs, paths, dotted table names, camelCase and acronym-led
  identifiers, SCREAMING_SNAKE env vars and `mcp__` tool names with typed
  placeholders. Verified zero residual hits for every project term across
  all 3,209 messages, with median word count unchanged at 33. Placeholders
  keep the token shape, since collapsing a path to `X` would change
  sentence length and rhythm, which is what the judge measures.
- **Drop unparseable verdicts, never score them as clean.** A timed-out
  call scored 0 would teach that the hardest messages are fine. Haiku lost
  59 of 300 to timeouts, which is why its n is 241 before alignment.
- **Do not trust small n.** Style kappa for Haiku vs Terra measured 0.68 at
  n=25, 0.71 at n=50, 0.48 at n=75, and 0.29 at n=121. The early estimate
  was more than double the settled value.

## Human false-positive test

Separate protocol, answering a different question: do the stage 1 and 1.5
thresholds fire on human technical prose?

```
git clone --filter=blob:none --no-checkout \
  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
git -C linux log --before=2022-11-30 --pretty=format:'%H%x09%B%x00'
```

Cut at 2022-11-30, the ChatGPT launch, so every hit is a false positive by
construction. Subject lines and trailer blocks are stripped, leaving 216,636
commit bodies of 15+ words; 20,000 sampled.

| check | human kernel | this corpus |
|---|---|---|
| negative parallelism | 0.1% | 12.0% |
| sentence over 40 words | 0.3% | 7.5% |
| significance coda | 1.4% | 2.6% |
| figures per paragraph | 3.2% | 4.3% |
| nominalization | 3.9% | 4.8% |
| any | 8.7% | 28.8% |

Negative parallelism separates 83:1 at a 1% human false-positive rate,
making it the strongest check in the suite.

Nominalization was removed from the blocking set on this evidence. It was
the best-replicated metric in the literature (d = 0.9 to 1.35 across two
corpora), and it shows no separation here. The published effect was
measured on academic prose, and software English is nominalized by nature.

Two caveats on reading the ratios. Kernel commits are ASCII by convention,
so the em dash comparison measures encoding habit as much as style. They
are also shorter, so the sentence-length gap is partly register. Both
overstate.
