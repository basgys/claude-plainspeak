#!/bin/bash
# Stop hook: per-turn gatekeeper for the final assistant message, judged on
# two independent axes (style, cognitive load) against CLAUDE.md's writing
# rules + common LLM-writing tells
# (en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Stateless — no
# memory of past turns, not a conversational agent.
#
# Stage 1: regex over banned words + known templated phrasings. Free,
# instant, catches most offenders. If it hits, block immediately.
# Stage 2: only runs when stage 1 passes clean. A one-shot Haiku classifier
# (--restricted, so it loads no settings/hooks and can't recursively trigger
# this hook, while still using normal account auth) whose sole job is
# spotting sentence-STRUCTURE tells regex can't reliably match (rule-of-
# three, hollow significance framing, throat-clearing, copula avoidance,
# paraphrased negative-parallelism). Keeps the common case free while still
# catching what regex misses.
#
# The COGNITIVE_LOAD rubric (both stages) is grounded in evidence-based
# communication research rather than ad-hoc judgment: BLUF/SBAR/Minto/
# inverted-pyramid all independently converge on "conclusion first"
# (buried-lede rule); SBAR's fixed slot order motivates the ask-before-
# context rule; Minto's MECE test motivates the grouping rule; Cowan
# (2001), "The magical number 4 in short-term memory" motivates the flat-
# list length ceiling; the Federal Plain Language Guidelines (Plain
# Writing Act of 2010) motivate the sentence-length ceiling and
# nominalization check; Sweller's redundancy effect motivates the
# redundancy rule. Citations are kept out of the runtime prompt itself —
# it's sent on every invocation, and the model needs the operational rule,
# not the citation.
set -uo pipefail

MAX_ATTEMPTS=3
METRICS="$(dirname "$0")/metrics.py"

input=$(cat)
session_id=$(jq -r '.session_id // "unknown"' <<<"$input")
counter_file="/tmp/.claude-sanity-attempts-${session_id}"

# stop_hook_active is false on the first Stop of a turn and true only when
# Claude is continuing because this hook blocked. Stop hooks don't fire on
# user interrupts, so a rewrite cut short by Escape never reaches pass()
# and leaves a counter behind — it must not carry into the next turn.
stop_hook_active=$(jq -r '.stop_hook_active // false' <<<"$input")
attempt=0
if [ "$stop_hook_active" = "true" ] && [ -f "$counter_file" ]; then
  attempt=$(cat "$counter_file" 2>/dev/null || echo 0)
else
  rm -f "$counter_file"
fi
[ -z "$attempt" ] && attempt=0

msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
[ -z "$msg" ] && exit 0

# A prior attempt already maxed out and gave up — don't re-enter.
if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
  rm -f "$counter_file"
  exit 0
fi

# A blocked draft stays in the transcript forever: no hook can retract or
# replace a message already displayed (verified against the hooks docs —
# Stop can only block, and MessageDisplay cannot). So a rewrite cycle leaves
# the reader several near-identical walls with no way to tell which one
# survived. The systemMessage prints directly under the message it judged,
# which makes it a verdict marker for the message ABOVE it: every draft gets
# one, so the reader scrolls for the green tick and reads only that.
# Every verdict is appended here, because without labels nothing
# downstream can be calibrated: the classifier's boundary is only as good
# as the target it aims at. Hashes the text rather than storing it, so the
# log carries no message content. Best-effort, never fails the hook.
LOGFILE="${PLAINSPEAK_LOG:-$HOME/.claude/plainspeak-verdicts.jsonl}"
log_verdict() { # stage, outcome, detail
  [ "${PLAINSPEAK_NOLOG:-}" = "1" ] && return 0
  mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || return 0
  local h m
  h=$(printf '%s' "$checktext" | shasum -a 256 2>/dev/null | cut -d' ' -f1)
  m=$(printf '%s' "$checktext" | python3 "$METRICS" 2>/dev/null)
  [ -z "$m" ] && m='{}'
  jq -cn --arg t "$(date -u +%FT%TZ)" --arg h "$h" --arg s "$1" \
        --arg o "$2" --arg d "$3" --argjson m "$m" \
    '{ts:$t, sha:$h, stage:$s, outcome:$o, detail:$d, metrics:$m}' \
    >> "$LOGFILE" 2>/dev/null || true
}

block() {
  attempt=$((attempt + 1))
  echo "$attempt" > "$counter_file"
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    jq -n --arg m "⚠️  KEPT AS-IS ↑ still failing after $MAX_ATTEMPTS attempts, gave up" \
      '{systemMessage: $m}'
    rm -f "$counter_file"
    exit 0
  fi
  # Stop hooks only honor decision/reason at the TOP level of the output
  # JSON. Nested under hookSpecificOutput they are silently ignored: the
  # systemMessage still prints, but the reply goes through unchanged.
  jq -n --arg r "$1 (attempt $attempt/$MAX_ATTEMPTS)" \
    --arg m "❌ DISCARDED ↑ do not read, rewriting ($attempt/$MAX_ATTEMPTS)" \
    '{decision: "block", reason: $r, systemMessage: $m}'
  exit 0
}

pass() {
  log_verdict all pass ""
  # Only mark the winner when there were losers above it to tell apart.
  if [ "$attempt" -gt 0 ]; then
    jq -n --arg m "✅ FINAL ANSWER ↑ read this one (passed after $attempt rewrite(s))" '{systemMessage: $m}'
  fi
  rm -f "$counter_file"
  exit 0
}

# Fenced code is never prose to be judged by writing rules — strip it.
# Blockquotes are NOT stripped: testing found the exemption is purely
# syntactic (matches a leading '>', not "is this actually someone else's
# words"), so it was a full bypass — wrap anything in blockquote formatting
# and both stages go blind to it. That happened non-adversarially too (an
# assistant's own commentary trailing off inside blockquote formatting).
# The cost of checking real quotes is low (quoted human/log text rarely
# contains AI-writing tells); the cost of the bypass was high.
checktext=$(awk '
  /^```/ { infence = !infence; next }
  infence { next }
  { print }
' <<<"$msg")

# --- Stage 1: patterns (part of the "fast checks" the hook reports) ---

# Hard list: CLAUDE.md's own explicit banned tokens. Zero tolerance by the
# user's own standing instruction — any occurrence blocks.
HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should (note|flag|mention|call out|point out|say)|it.s worth noting)\b'

# Soft list: words that are fine on a single, ordinary use but are the tell
# when repeated — the actual complaint is "this appears every sentence",
# not "this word exists". Requires >=2 total hits to flag.
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'

PHRASE_PATTERN='not (just |merely |simply )?[a-zA-Z ]{1,40}(,? but |, it.s )|not (just |only )?about [a-zA-Z ]{1,40}(,? it.s about|, but about)|whether (you.re|it.s|this is) [a-zA-Z ]{1,30}(,| or)|in (today.s|this) (fast-paced|ever-evolving|ever-changing) world|when it comes to|at the end of the day|let.s (dive|break|unpack)|unlock the (power|potential) of|navigate the complexities|harness the power of|embark on (a|an|this)|seamless(ly)? integrat|(stands|serves) as a (testament|reminder)|is a testament to|plays a (crucial|pivotal|vital|key) role|sets the stage for|underscores? (its|the) importance|,\s*(highlighting|underscoring|emphasizing|reflecting|symbolizing|demonstrating|showcasing) (the|its|how|that)|\bin (connection|association) with\b|\b(widely|particularly) associated with\b|(^|[.!?] )rather, (it|this|that|they|the)\b|\bno [a-z]+, no [a-z]+, just\b|(^|[.!?] )(here.s|here is) (what|the (thing|key|short)) |\b(two|three|four) things (I|to) (should |want to )?(flag|note|mention|call out)\b|\bworth (acting on|flagging|watching|highlighting|calling out|raising)\b|\bone to watch\b'

# Significance coda: a clipped verdict, a comma, then a coordinated clause
# asserting that the thing matters, in place of showing why. "Mixed, and
# the split matters." "Modelled, and the model is mine." Wikipedia files
# the family under undue emphasis on symbolism and importance; this
# compressed form has no name there. It reads as portent and carries no
# information: the reader learns something is significant without learning
# what follows from it.
#
# Blocks on one occurrence. A bare fragment opener is fine on its own
# ("Done, and pushed."), so the pattern requires the significance tail or
# the self-referential reframe that makes it a coda.
SIGNIFICANCE_CODA_PATTERN='\b(and|but) (the|that|this|it|those|these) [a-z]{2,14}( [a-z]{2,14})?( (really|actually|genuinely))? (matters|is the point|counts|is what counts|makes the difference|changes everything)\b|\b(that|this|which)( part| bit)? (really |actually )?matters\b|(^|[.!?] )[A-Z][a-z]{2,12}(ed)?, (and|but) (the|that|this|it) [a-z]{2,14} (is|are|was|were|comes|come|belongs|follows)\b'

# Negative parallelism, the trailing-appositive form: state the thing, then
# negate an alternative nobody proposed ("it samples the container's cgroup
# limits rather than the node's", "queued, waiting for a slot, not executing
# slowly", "the pool belongs to the instance, not to a connection"). The
# negation carries no information; it doubles the length and reads as
# hedging. Wikipedia lists this as three subtypes — "not just X but Y",
# "not X, but Y", "X rather than Y" — of which PHRASE_PATTERN above only
# catches the two that end in "but".
#
# Counted rather than hard-blocked: a single one is sometimes a real
# contrast against something the reader actually believes ("it's a warning,
# not an error"), which regex can't tell apart from the tic. Two or more in
# one message is the verbal habit, and Haiku (stage 2) judges the singles.
NEG_PARALLEL_PATTERN='(,|—|;) *not +(just |only |merely |simply )?[a-z0-9"]|\brather than\b|\bnot +(a|an|the|to|because|from) [a-z]+,? but\b'

# Nominalization ("the implementation of" vs "implementing") is judged by
# Haiku (stage 2) only, not regexed here: testing found "the X of" false-
# positives on ordinary technical nouns like "the configuration of the
# load balancer", where "configuration" is a concrete noun, not a verb in
# hiding. Telling the two apart needs the judgment a regex can't do.

hits=""
hard_m=$(grep -oiE "$HARD_WORD_PATTERN" <<<"$checktext" 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u | paste -sd, -)
[ -n "$hard_m" ] && hits="banned words: $hard_m"

soft_all=$(grep -oiE "$SOFT_WORD_PATTERN" <<<"$checktext" 2>/dev/null | tr '[:upper:]' '[:lower:]')
soft_count=$(wc -l <<<"$soft_all" | tr -d ' ')
[ -z "$soft_all" ] && soft_count=0
if [ "$soft_count" -ge 2 ]; then
  soft_m=$(sort -u <<<"$soft_all" | paste -sd, -)
  hits="${hits:+$hits; }repeated AI-vocab ($soft_count occurrences: $soft_m)"
fi

if grep -qiE "$PHRASE_PATTERN" <<<"$checktext"; then
  hits="${hits:+$hits; }templated LLM phrasing (not-X-but-Y / throat-clearing / hollow significance)"
fi

# --- Stage 1.5: structured metrics (stdlib Python, 0.35ms/message) ----
# The patterns above catch literal forms. metrics.py catches shapes needing
# a count or a two-clause test, benchmarked across 3,209 real messages.
# Silently skipped when python3 is absent, leaving the bash checks intact.
if [ -f "$METRICS" ] && command -v python3 >/dev/null 2>&1; then
  m=$(printf '%s' "$checktext" | python3 "$METRICS" 2>/dev/null)
  if [ -n "$m" ]; then
    coda=$(jq -r '.coda // 0' <<<"$m" 2>/dev/null || echo 0)
    coda_ex=$(jq -r '.coda_hits[0] // ""' <<<"$m" 2>/dev/null)
    nom=$(jq -r '.nominal_per_100w // 0' <<<"$m" 2>/dev/null)
    nom_ex=$(jq -r '.nominal_hits | join(", ")' <<<"$m" 2>/dev/null)
    negflag=$(jq -r '.neg_parallel_flag // false' <<<"$m" 2>/dev/null)
    negn=$(jq -r '.neg_parallel // 0' <<<"$m" 2>/dev/null)
    if [ "$negflag" = "true" ]; then
      hits="${hits:+$hits; }negative parallelism (x$negn): stating what is NOT the case right after stating what is. Delete the negated half; if nothing is lost, cut it"
    fi
    if [ "${coda:-0}" -ge 1 ] 2>/dev/null; then
      hits="${hits:+$hits; }significance coda (\"$coda_ex\"): a verbless fragment, then a clause commenting on it. Say what follows from it, or cut the clause"
    fi
    # Nominalization is measured and reported, never blocked. It was the
    # best-replicated metric in the literature (d = 0.9 to 1.35 across two
    # corpora), and it does not survive contact with this corpus: against
    # 20,000 pre-ChatGPT Linux kernel commit bodies it fires on 3.9% of
    # human prose against 4.8% here. At a 1% human false-positive rate it
    # separates 0.9% to 1.0%, which is no separation at all. Software
    # English is congenitally nominalized and the published effect was
    # measured on academic prose, so the register is wrong.
    :
  fi
fi

# Literal-form coda, kept as a floor under the two-clause test.
coda_m=$(grep -oiE "$SIGNIFICANCE_CODA_PATTERN" <<<"$checktext" 2>/dev/null | head -3 | paste -sd'; ' -)
if [ -n "$coda_m" ]; then
  hits="${hits:+$hits; }significance coda ($coda_m) — say what follows from it, or cut the clause"
fi

# The bash counter that lived here is retired. metrics.py now decides
# this with two tiers, measured against 262 messages where two independent
# judges agreed: a single strict hit blocks, and the looser "instead of"
# form needs a second hit. That took the fast checks from 89% to 95%
# recall at 90% precision.

emdash_count=$(grep -o '—' <<<"$checktext" 2>/dev/null | wc -l | tr -d ' ')
[ -z "$emdash_count" ] && emdash_count=0
word_count=$(wc -w <<<"$checktext" | tr -d ' ')
emdash_budget=$((word_count / 150))
[ "$emdash_budget" -lt 3 ] && emdash_budget=3
if [ "$emdash_count" -gt "$emdash_budget" ]; then
  hits="${hits:+$hits; }em dash overused ($emdash_count in $word_count words, budget $emdash_budget)"
fi

# Federal Plain Language ceiling: ~40 words/sentence. Split on ./!/?/;/:
# — testing found a semicolon-joined enumeration ("risk A; risk B; risk C")
# is dense, legitimate writing, not one padded run-on sentence; each clause
# is its own unit and should be measured separately. A colon counts too: it
# introduces a list rather than continuing the clause.
#
# Measured per LINE, never across newlines. The original RS spanned lines,
# so a bullet list or a table with no terminal punctuation fused into one
# giant "sentence" (a 4-item list of stats measured 55 words) and blocked
# every rewrite attempt until the hook gave up. Table rows and list markers
# are stripped or skipped for the same reason: they are layout, not prose.
longest_sentence=$(awk '
  { line = $0
    if (line ~ /^[ \t]*[|│┌└├┐┘┤┬┴┼]/) next
    sub(/^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/, "", line)
    sub(/^[ \t]*#+[ \t]+/, "", line)
    n = split(line, parts, /[.!?;:]+[ \t]+/)
    for (i = 1; i <= n; i++) {
      c = split(parts[i], w, /[ \t]+/)
      if (c > max) max = c
    }
  }
  END { print max+0 }
' <<<"$checktext")
if [ "$longest_sentence" -gt 40 ]; then
  hits="${hits:+$hits; }sentence too long ($longest_sentence words, Federal Plain Language ceiling is ~40)"
fi

# Cowan (2001) again, applied to figures rather than list items: a prose
# paragraph carrying seven durations and counts forces the reader to hold
# all of them to follow the argument. A real message did exactly this
# (17h46m, 7 stacked, 599 queued, 17h55m, 20h9m, 19h25m, 4h29m in four
# sentences) and stage 2 passed it, because a general "respect working
# memory" principle is too soft to fire on.
#
# Prose only. Tables and lists are exempt: those are scanned column-wise
# and put no load on memory, and benchmark rows legitimately carry many
# figures. Identifiers (list.go:412, lake.foreach.diff, steam_app) are not
# quantities and are excluded by the token shape.
dense_para=$(awk '
  function flush(  n, i, tok, t, c) {
    if (para == "") return
    c = 0
    n = split(para, t, /[ \t]+/)
    for (i = 1; i <= n; i++) {
      tok = t[i]
      gsub(/^[(\[]|[.,;:)\]]+$/, "", tok)
      if (tok ~ /^[0-9][0-9,]*(\.[0-9]+)?(h[0-9]+m|m[0-9]+s|[hmsd]|%|x|GB|MB|KB|ms)?$/) c++
    }
    if (c > max) max = c
    para = ""
  }
  /^[ \t]*$/ { flush(); next }
  /^[ \t]*([-*+]|[0-9]+[.)])[ \t]/ { flush(); next }
  /^[ \t]*[|│┌└├┐┘┤┬┴┼]/ { flush(); next }
  { para = para " " $0 }
  END { flush(); print max+0 }
' <<<"$checktext")
if [ "$dense_para" -gt 5 ]; then
  hits="${hits:+$hits; }too many figures in one prose paragraph ($dense_para — move them to a list or table, or cut to the ones that carry the argument)"
fi
# The terminal-state check lived here and was removed. Measured against
# 3,209 real messages it fired on 17.6% of those over 150 words, and 67%
# of the hits were wrong at every word floor tried, which pointed at the
# keyword list rather than the writing. Sampling confirmed it: "Say the
# word and I'll apply 1 and 2" and "Approve and I'll build it" are
# unambiguous terminal states it missed. Enumerating every valid ending is
# the wrong shape for a keyword list, so principle 6 is judged by stage 2
# alone.


# Cowan (2001)'s ~4-chunk comfortable limit is for material held in working
# memory at once. A sequential checklist (read-and-execute-in-order, e.g.
# setup steps) isn't held simultaneously the way a list of facts is, and
# testing found genuinely necessary 8-step checklists getting flagged at
# the original threshold of 6 — loosened to 10 as a looser "too long even
# for sequential reading" ceiling, not Cowan's comfortable number.
max_bullets=$(awk '/^[-*][ \t]/{c++; if(c>max) max=c; next} {c=0} END{print max+0}' <<<"$checktext")
if [ "$max_bullets" -gt 10 ]; then
  hits="${hits:+$hits; }flat list too long ($max_bullets items — even for sequential reading, consider grouping)"
fi

if [ -n "$hits" ]; then
  log_verdict fast block "$hits"
  block "Style [fast checks]: $hits. Cut the flagged constructions, keep it terse. Fenced code is exempt; blockquotes are not."
fi

# --- No model judge ---------------------------------------------------
# The Haiku call lived here and was removed. It cost 27-79 seconds on every
# turn, and by the time the Python metrics absorbed negative parallelism
# they were catching 95% of what two independent judges agree on, at 90%
# precision.
#
# What that costs, measured on 300 messages labelled by Terra and Luna
# (kappa 0.71): of the 80 that pass every fast check, 16 are still
# consensus violations, so roughly a fifth of the clean-looking band now
# ships unjudged. Those are predominantly cognitive-load items no regex
# sees: throat-clearing, a buried finding, an invented caveat.
#
# The trade was made deliberately. A local check that runs in 250ms and
# catches most of it beats a remote one that runs in a minute and catches
# slightly more. New examples feed the Python rules instead.
#
# judge/rubric.txt keeps the rubric these judges read, so
# docs/judge-benchmark.md stays reproducible and the model judge can be
# reinstated by measurement rather than rewritten from memory.
log_verdict fast pass ""
pass
