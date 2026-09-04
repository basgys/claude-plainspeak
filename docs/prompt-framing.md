# Prompt framing

Does telling the model about consequences make it write better? Measured,
because the answer was not obvious and one popular idea turned out to be
worthless.

## Results

400 generations: 100 real user prompts drawn from local transcripts, four
system-prompt conditions, Sonnet at low effort, 120-250 words of prose each.
Scored by `hooks/metrics.py` plus the banned-word list, so "blocked" means
the Stop hook would have rejected it.

| condition | blocked | 95% CI | negative parallelism | long sentence | words |
|---|---|---|---|---|---|
| current rules | 48% | 38-58% | 38% | 16% | 135 |
| + harsh penalty | 47% | 37-57% | 37% | 14% | 144 |
| + reader sensitivity, quoted | 31% | 22-40% | 27% | 5% | 127 |
| + reader sensitivity, unquoted | 36% | 27-45% | 32% | 4% | 126 |

Pooled, 200 per group:

| | blocked |
|---|---|
| without sensitivity framing | 48% |
| with sensitivity framing | 34% |
| difference | **14 points, p=0.004** |

An earlier 24-prompt pilot also ran a no-rules arm at **88% blocked** and a
69-word cut-down arm at **71%**. Rule coverage does the heavy lifting;
framing tunes it.

## What works

**Naming the reader and framing the rules as an accessibility requirement.**
Cuts the block rate by 14 points. The effect concentrates on the target
construction: negative parallelism falls from 38% to 27%, and sentences over
40 words fall from 16% to 4%.

The shipped text is at the end of `hooks/style-rules.sh`. It states that the
reader finds these constructions painful, that repeated use after a clear
request reads as disregard, and that hard-to-parse structure is an
accessibility problem of the same kind.

## What does not work

**Threatening the model.** A harsh-penalty framing, telling it the draft
would be discarded, the reader would watch it thrown away, and three
failures would ship it broken, moved the block rate by one point: 47%
against 48%, p=0.89.

This is worth stating plainly because the idea is intuitive and wrong. The
plugin had carried a milder version of the same framing for weeks
("failing costs the reader a discarded draft they have to scroll past") with
no measurable benefit.

The likely reason: a penalty is a consequence for the writer, which is
abstract and easy to discount at the moment of writing a sentence. Naming
the reader changes who the text is for, which is something a model can act
on sentence by sentence.

**Cutting the rules down.** A 69-word version keeping only the strongest
rule scored 71% blocked against 48% for the full 385-word version. Coverage
beats brevity here.

## Caveats

Measured on Sonnet at low effort, which may not transfer identically to a
larger model writing the actual replies.

34% is still a high block rate. This reduces the problem rather than solving
it.

The quoted and unquoted sensitivity variants are statistically
indistinguishable (31% vs 36%, p=0.45). The unquoted one ships, since
putting the user's words in every system prompt buys nothing measurable.

## Reproducing

The generation harness lives in the scratchpad rather than the repo, since
it depends on a local transcript corpus. To rebuild it: extract user
messages of 12-60 words from `~/.claude/projects/**/*.jsonl`, generate one
reply per prompt per condition through `claude -p` with the condition as
system prompt, then score with `hooks/metrics.py`.

Use at least 100 prompts per arm. A 24-prompt pilot put the penalty arm 9
points *worse* than baseline, which vanished at n=100.
