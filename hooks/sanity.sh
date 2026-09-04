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

# --- Stage 1: regex ---------------------------------------------------

# Hard list: CLAUDE.md's own explicit banned tokens. Zero tolerance by the
# user's own standing instruction — any occurrence blocks.
HARD_WORD_PATTERN='\b(load-bearing|crux|honest answer|honest solution|delve|nuanced|tapestry|leverage|utilize|robust|innovative|streamline|great question|good point|absolutely|certainly|of course|awesome|honestly|to be clear|fair point|fair pushback|I should note|it.s worth noting)\b'

# Soft list: words that are fine on a single, ordinary use but are the tell
# when repeated — the actual complaint is "this appears every sentence",
# not "this word exists". Requires >=2 total hits to flag.
SOFT_WORD_PATTERN='\b(boasts?|bolstered|testament|vibrant|showcas(e|es|ing)|groundbreaking|game.?changer|cutting.?edge|paradigm shift|holistic approach|synergy|underscores?|exemplifies|nestled|in the heart of)\b'

PHRASE_PATTERN='not (just |merely |simply )?[a-zA-Z ]{1,40}(,? but |, it.s )|not (just |only )?about [a-zA-Z ]{1,40}(,? it.s about|, but about)|whether (you.re|it.s|this is) [a-zA-Z ]{1,30}(,| or)|in (today.s|this) (fast-paced|ever-evolving|ever-changing) world|when it comes to|at the end of the day|let.s (dive|break|unpack)|unlock the (power|potential) of|navigate the complexities|harness the power of|embark on (a|an|this)|seamless(ly)? integrat|(stands|serves) as a (testament|reminder)|is a testament to|plays a (crucial|pivotal|vital|key) role|sets the stage for|underscores? (its|the) importance|,\s*(highlighting|underscoring|emphasizing|reflecting|symbolizing|demonstrating|showcasing) (the|its|how|that)|\bin (connection|association) with\b|\b(widely|particularly) associated with\b|(^|[.!?] )rather, (it|this|that|they|the)\b|\bno [a-z]+, no [a-z]+, just\b'

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

neg_all=$(grep -oiE "$NEG_PARALLEL_PATTERN" <<<"$checktext" 2>/dev/null)
neg_count=$(wc -l <<<"$neg_all" | tr -d ' ')
[ -z "$neg_all" ] && neg_count=0
if [ "$neg_count" -ge 2 ]; then
  hits="${hits:+$hits; }negative parallelism x$neg_count (stating what is NOT the case right after stating what is — 'X, not Y' / 'X rather than Y'; the negation adds nothing, cut it)"
fi

# Density, not an absolute count: the tell is em dashes every other
# sentence, so a fixed ceiling of 3 punished long structured answers for
# their length alone. One block cost a full discarded draft over 3 dashes
# in ~430 words, and the rewrite only swapped them for commas — the reader
# scrolled a near-identical wall to find one cosmetic diff. Allow 1 per 150
# words, floor 3, so a short reply still cannot stack them.
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
  block "Style [regex]: $hits. Cut the flagged constructions, keep it terse. Fenced code is exempt; blockquotes are not."
fi

# --- Stage 2: structural check via Haiku, only when stage 1 passed ----

# Measured 32-58s on a 235-word message: the rubric and the required
# rewrite suggestions drive it, not the input (the same text with a trivial
# prompt returns in 8s). --effort low made no difference (32s, 64s).
# The harness timeout is 60s; bound the call at 45s from inside so the
# script keeps enough time to say the check was skipped. Without this the
# hook is killed outright and the message ships silently unchecked.
CLASSIFIER_TIMEOUT=45
timeout_cmd=""
command -v timeout >/dev/null 2>&1 && timeout_cmd="timeout $CLASSIFIER_TIMEOUT"
command -v gtimeout >/dev/null 2>&1 && timeout_cmd="gtimeout $CLASSIFIER_TIMEOUT"

verdict=$($timeout_cmd claude --restricted --model haiku --system-prompt "You are a precise text classifier. Follow only the instructions in the user's message, and reply in exactly the format it requests." --no-session-persistence -p "You judge one message against one person's writing rules, on TWO independent axes. Report both, even if one is clean.

AXIS 1 — STYLE: mechanical AI-writing tells (paraphrases count, not just exact wording).
- Filler/hedging, banned stock phrases, corporate vocabulary (crucial, delve, robust, leverage, testament, etc.)
- Rule-of-three lists used as filler, hollow significance framing ('X reflects/underscores a deeper Y')
- Throat-clearing before the answer
- NEGATIVE PARALLELISM — the single highest-priority tell here, flag it even once. The writer states what IS the case and then negates an alternative nobody raised. All of these forms count:
  * 'It's not X, it's Y' / 'not just X, but Y' (the classic strawman)
  * trailing appositive: 'it belongs to the instance, not to a connection', 'queued, waiting for a slot, not executing slowly', 'reporting only, not the tuner'
  * 'rather than' / 'instead of': 'it samples the container's cgroup limits rather than the node's'
  The test: delete the negated half. If the sentence still says everything the reader needed, the negation was zero-information padding and IS a violation — prefer the sentence with it cut ('it samples the container's cgroup limits'). Do not accept it because it 'adds precision': stating what you are doing already excludes what you are not doing.
  Only genuine correction survives: the negated alternative is one the reader actually expects or has just asserted, and naming it resolves a live confusion (e.g. 'that's a warning, not an error' when they read it as a failure). Absent that, flag it.
- Do NOT flag a direct 'No,'/'Yes,' answer to a yes/no question followed by a brief gloss (e.g. 'No, not automatically — it runs on save.') — that is answering the question.
- Copula avoidance ('serves as' instead of 'is')
- Hidden-verb nominalization ('the implementation of X' instead of 'implementing X') — only when a plain verb genuinely reads better; do NOT flag ordinary concrete nouns like 'the configuration of the load balancer', where the noun names a real thing, not a disguised action

AXIS 2 — COGNITIVE_LOAD: protect the reader's attention, their scarcest resource. Every sentence that costs extra parsing effort without adding real information is a defect. Six general principles, each stated as prefer/avoid so the target behavior is explicit, not just the prohibition:
1. Point first. Prefer: open with the main point (answer, finding, conclusion). Avoid: reasoning or elaboration before it.
2. Context before ask. Prefer: state the situation, then the ask; for a genuine question offering the reader a choice, ALWAYS include a recommended option with one brief reason, even for a short single-sentence question. Avoid: asking before context, or a question that presents options/alternatives with no stated recommendation at all (check this explicitly — it is easy to miss on short messages).
3. Clean structure. Prefer: groupings/lists that are genuinely distinct and complete. Avoid: overlapping or gap-leaving categories, or padding a list to hit a count.
4. Say only what's warranted. Two root causes when this fails: sycophancy (manufacturing agreeable-sounding content to match perceived expectations rather than what the situation actually supports) and verbosity/length bias (padding output because length itself got learned as a proxy for perceived thoroughness, independent of whether it adds information). Prefer: state what's actually true or needed here, then stop. Avoid: restating what's already visible elsewhere in the text, inventing a caveat/tradeoff just to look thorough, or elaborating past what was asked.
5. Respect working-memory limits. Prefer: sentences and lists short enough to hold in the head at once. Avoid: long unbroken sentences or long flat lists.
6. Unambiguous terminal state. Prefer: end by naming one of a small set of plain states (e.g. done; blocked, needs X). Avoid: hedging or trailing off so the ending must be inferred. This checks clarity of what's said, not whether it's true.

Never flag on either axis: code blocks, inline code, file paths, commands, error strings, identifiers, numbers, or anything the author is quoting/relaying verbatim (another person's words, a file's contents, a tool's output) rather than writing themselves — content the author didn't compose isn't theirs to be judged on. Fenced code has already been stripped from the text below. Markdown blockquote lines (starting with '>') have NOT been stripped — judge them: if a '>' line reads like a genuine external quote (an error message, someone else's words), don't flag it; if it reads like the author's own commentary or opinion continuing in blockquote formatting, it's authored text and IS subject to both axes like anything else.
Do NOT flag: plain technical writing, terse fragments, legitimate lists of genuinely distinct facts, normal use of 'and'/'but'. A word from the checklist below used ONCE, in an ordinary sentence, is not a violation by itself — the tell is the word recurring or the sentence being built around it, not its mere presence.

Per axis: VIOLATION only when you are sure the reader would notice it. NOTE when something feels off but you are not certain enough to force a rewrite — these are surfaced to the reader, not auto-corrected.

Whenever you flag VIOLATION or NOTE, include a concrete preferred alternative — the actual replacement wording or structure, not just a description of what's wrong. If no rewrite is obviously better (e.g. the fix is 'just cut this sentence'), say that instead.

Reply with EXACTLY two lines, this format, nothing else:
STYLE: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>
COGNITIVE_LOAD: OK|VIOLATION: <fragment> — <reason> — prefer: <replacement or 'cut it'>|NOTE: <fragment> — <reason> — prefer: <replacement or 'cut it'>

TEXT:
$checktext" 2>/dev/null)

# A silent pass here is the dangerous failure: an empty verdict parses as
# "no VIOLATION found" and the message ships as if it had been checked.
if [ -z "$verdict" ] || [[ "$verdict" != *"STYLE:"* ]]; then
  jq -n --arg m "⚠️  UNCHECKED ↑ stage 2 classifier timed out or failed; regex checks passed" \
    '{systemMessage: $m}'
  rm -f "$counter_file"
  exit 0
fi

style_val="${verdict#*STYLE: }"
style_val="${style_val%%$'\n'*}"
cog_val="${verdict#*COGNITIVE_LOAD: }"

violations=""
notes=""

if [[ "$style_val" == VIOLATION:* ]]; then
  violations="style: ${style_val#VIOLATION: }"
elif [[ "$style_val" == NOTE:* ]]; then
  notes="style: ${style_val#NOTE: }"
fi

if [[ "$cog_val" == VIOLATION:* ]]; then
  violations="${violations:+$violations; }cognitive-load: ${cog_val#VIOLATION: }"
elif [[ "$cog_val" == NOTE:* ]]; then
  notes="${notes:+$notes; }cognitive-load: ${cog_val#NOTE: }"
fi

if [ -n "$violations" ]; then
  block "Style [$violations]"
fi

if [ -n "$notes" ]; then
  jq -n --arg m "Style note (not blocking): $notes" '{systemMessage: $m}'
  rm -f "$counter_file"
  exit 0
fi

pass
